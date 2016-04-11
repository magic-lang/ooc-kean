/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Backtrace

include setjmp, stdint

JmpBuf: cover from jmp_buf {
	setJmp: extern (setjmp) func -> Int
	longJmp: extern (longjmp) func (value: Int)
}

_StackFrame: cover {
	buf: JmpBuf
}

StackFrame: cover from _StackFrame* {
	new: static func -> This {
		calloc(1, _StackFrame size)
	}
	free: func {
		memfree(this as Void*)
	}
}

ExceptionContext: class {
	_exceptionJumpLabel := 1
	_localFrames := Stack<StackFrame> new()
	_currentException: Exception
	_stackFramesToDelete := Stack<StackFrame> new()
	exception: Exception {
		get { this _currentException }
		set (value) { this _currentException = value }
	}
	init: func
	pushStackFrame: func -> StackFrame {
		frame := StackFrame new()
		this _localFrames push(frame)
		frame
	}
	cleanupStackFrames: func {
		while (!this _stackFramesToDelete isEmpty)
			if ((frame := this _stackFramesToDelete pop()))
				frame free()
	}
	popStackFrame: func {
		if ((frame := this _localFrames pop()))
			frame free()
		this cleanupStackFrames()
	}
	takeStackFrame: func -> StackFrame {
		frame := this _localFrames pop()
		this _stackFramesToDelete push(frame)
		frame
	}
	hasStackFrame: func -> Bool {
		!this _localFrames isEmpty
	}
}

exceptionContext := ExceptionContext new()

_pushStackFrame: func -> StackFrame { exceptionContext pushStackFrame() }
_popStackFrame: func { exceptionContext popStackFrame() }
_getException: func -> Exception { exceptionContext exception }

version(windows) {
	getOSErrorCode: func -> Int { GetLastError() }
	getOSError: func -> String { GetWindowsErrorMessage(GetLastError()) }
} else {
	getOSErrorCode: func -> Int {
		errno
	}
	getOSError: func -> String {
		x := strerror(errno)
		(x != null) ? x toString() : ""
	}
}

raise: func ~withClass (message: String, origin: Class = null) { Exception new(origin, message) throw() }
raise: func ~assert (condition: Bool, message: String, origin: Class = null) {
	if (condition)
		raise(message, origin)
}
raise: func ~textWithClass (message: Text, origin: Class = null) { raise(message toString(), origin) }
raise: func ~textAssert (condition: Bool, message: Text, origin: Class = null) {
	if (condition)
		raise(message, origin)
}

Exception: class {
	backtraces := Stack<Backtrace> new()
	origin: Class
	message: String

	init: func (=origin, =message)
	init: func ~noOrigin (=message) { this init(null, message) }
	free: override func {
		while (!this backtraces isEmpty) {
			backtrace := this backtraces pop()
			if (backtrace)
				backtrace free()
		}
		this backtraces free()
		super()
	}
	addBacktrace: func {
		backtrace := BacktraceHandler get() backtrace()
		if (backtrace)
			this backtraces push(backtrace)
	}
	printBacktrace: func {
		handler := BacktraceHandler get()
		for (i in 0 .. this backtraces count)
			stderr write(handler backtraceSymbols(this backtraces peek(i)))
	}
	formatMessage: func -> String {
		if (this origin)
			"[%s in %s]: %s\n" format(this class name toCString(), this origin name toCString(), this message ? this message toCString() : "<no message>" toCString())
		else
			"[%s]: %s\n" format(this class name toCString(), this message ? this message toCString() : "<no message>" toCString())
	}
	print: func {
		this printMessage()
		this printBacktrace()
	}
	printMessage: func {
		fprintf(stderr, "%s", this formatMessage() toCString())
	}
	throw: func {
		exceptionContext exception = this
		this addBacktrace()
		if (!exceptionContext hasStackFrame()) {
			version (windows) {
				if (IsDebuggerPresent()) {
					// trigger a break point here, debugger will like that!
					this printMessage()
					DebugBreak()
				} else
					this print()
				exit(1)
			} else {
				this printMessage()
				abort()
			}
		} else {
			frame := exceptionContext takeStackFrame()
			frame@ buf longJmp(exceptionContext _exceptionJumpLabel)
		}
	}
	rethrow: func {
		this throw()
	}
	getCurrentBacktrace: static func -> String {
		result: String
		handler := BacktraceHandler get()
		backtrace := handler backtrace()
		if (backtrace) {
			result = handler backtraceSymbols(backtrace)
			backtrace free()
		} else
			result = "[no backtrace] use a debugger!\n"
		result
	}
}

OSException: class extends Exception {
	init: func (=message) {
		init()
	}
	init: func ~noOrigin {
		errorCode := getOSError()
		if ((this message != null) && (!this message empty()))
			this message = this message append(':') append(errorCode)
		else
			this message = errorCode
	}
}

OutOfBoundsException: class extends Exception {
	init: func (=origin, accessOffset, elementLength: Int) {
		init(accessOffset, elementLength)
	}
	init: func ~noOrigin (accessOffset, elementLength: Int) {
		this message = "Trying to access an element at offset %i, but size is %i!" format(accessOffset, elementLength)
	}
	kean_exception_outOfBoundsException_throw: static unmangled func (accessOffset, elementLength: Int) {
		This new(accessOffset, elementLength) throw()
	}
}

OutOfMemoryException: class extends Exception {
	init: func (=origin) {
		init()
	}
	init: func ~noOrigin {
		this message = "Failed to allocate more memory!"
	}
}

/* -------- Signal / exception catching ---------- */

version ((linux || apple) && !android) {
	_signalHandler: func (sig: Int) {
		message := match sig {
			case SIGHUP => "(SIGHUP) terminal line hangup"
			case SIGINT => "(SIGINT) interrupt program"
			case SIGILL => "(SIGILL) illegal instruction"
			case SIGTRAP => "(SIGTRAP) trace trap"
			case SIGABRT => "(SIGABRT) abort program"
			case SIGFPE => "(SIGFPE) floating point exception"
			case SIGBUS => "(SIGBUS) bus error"
			case SIGSEGV => "(SIGSEGV) segmentation fault"
			case SIGSYS => "(SIGSYS) non-existent system call invoked"
			case SIGPIPE => "(SIGPIPE) write on a pipe with no reader"
			case SIGALRM => "(SIGALRM) real-time timer expired"
			case SIGTERM => "(SIGTERM) software termination signal"
			case => "(?) unknown signal %d" format(sig)
		}
		stderr write(message) . write('\n')
		stderr write(Exception getCurrentBacktrace())
		exit(sig)
	}
}

version (windows) {
	_unhandledExceptionHandler: func (exceptionInfo: EXCEPTION_POINTERS*) -> DWORD {
		code := exceptionInfo@ ExceptionRecord@ ExceptionCode
		message := match code {
			case EXCEPTION_ACCESS_VIOLATION => "(ACCESS_VIOLATION) tried to read from or write to a virtual address without the appropriate access."
			case EXCEPTION_ARRAY_BOUNDS_EXCEEDED => "(ARRAY_BOUNDS_EXCEEDED) tried to access an array element that is out of bounds"
			case EXCEPTION_BREAKPOINT => "(BREAKPOINT) a breakpoint was encountered"
			case EXCEPTION_DATATYPE_MISALIGNMENT => "(DATATYPE_MISALIGNMEN) tried to read or write misaligned data on hardware that does not provide alignment"
			case EXCEPTION_FLT_DENORMAL_OPERAND => "(FLT_DENORMAL_OPERAND) an operand to a floating point operation is denormal (too small)"
			case EXCEPTION_FLT_DIVIDE_BY_ZERO => "(FLT_DIVIDE_BY_ZERO) tried to divide a floating point value by zero"
			case EXCEPTION_FLT_INEXACT_RESULT => "(FLT_INEXACT_RESULT) the result of a floating point operation cannot be represented as a fraction"
			case EXCEPTION_FLT_INVALID_OPERATION => "(FLT_INVALID_OPERATION) other floating point error"
			case EXCEPTION_FLT_OVERFLOW => "(FLT_OVERFLOW) exponent of a floating-point operation greater than allowed by the type"
			case EXCEPTION_FLT_STACK_CHECK => "(FLT_STACK_CHECK) stack overflow or underflow as a result of a floating point operation"
			case EXCEPTION_FLT_UNDERFLOW => "(FLT_UNDERFLOW) exponent of a floating-point operation less than allowed by the type"
			case EXCEPTION_ILLEGAL_INSTRUCTION => "(ILLEGAL_INSTRUCTION) tried to execute an invalid instruction"
			case EXCEPTION_IN_PAGE_ERROR => "(IN_PAGE_ERROR) tried to access a page that was not present and that the system failed to load"
			case EXCEPTION_INT_DIVIDE_BY_ZERO => "(INT_DIVIDE_BY_ZERO) tried to divide an integer value by zero"
			case EXCEPTION_INT_OVERFLOW => "(INT_OVERFLOW) integer operation caused to carry out the most significant bit"
			case EXCEPTION_INVALID_DISPOSITION => "(INVALID_DISPOSITION) exception handler returned an invalid disposition"
			case EXCEPTION_NONCONTINUABLE_EXCEPTION => "(NONCONTINUABLE_EXCEPTION) tried to continue after a non-continuable exception"
			case EXCEPTION_PRIV_INSTRUCTION => "(PRIV_INSTRUCTION) tried to execute an instruction not allowed in the current machine mode"
			case EXCEPTION_SINGLE_STEP => "(SINGLE_STEP) trace trap or other mechanism signaled that one action was executed"
			case EXCEPTION_STACK_OVERFLOW => "(STACK_OVERFLOW) the thread used up its stack"
			case => "(?) unknown exception code %lu" format(code as ULong)
		}
		stderr write(message) . write('\n')
		handler := BacktraceHandler get()
		context := exceptionInfo@ ContextRecord as Pointer
		backtrace := handler backtraceWithContext(context)
		if (backtrace)
			stderr write(handler backtraceSymbols(backtrace))
		else
			stderr write("[no backtrace] use a debugger!")
		EXCEPTION_EXECUTE_HANDLER
	}
}

_setupHandlers: func {
	version ((linux || apple) && !android) {
		signal(SIGHUP, _signalHandler)
		signal(SIGINT, _signalHandler)
		signal(SIGILL, _signalHandler)
		signal(SIGTRAP, _signalHandler)
		signal(SIGABRT, _signalHandler)
		signal(SIGFPE, _signalHandler)
		signal(SIGBUS, _signalHandler)
		signal(SIGSEGV, _signalHandler)
		signal(SIGSYS, _signalHandler)
		signal(SIGPIPE, _signalHandler)
		signal(SIGALRM, _signalHandler)
		signal(SIGTERM, _signalHandler)
	}

	version (windows) {
		SetUnhandledExceptionFilter(_unhandledExceptionHandler as Pointer)
	}
}

_setupHandlers()
