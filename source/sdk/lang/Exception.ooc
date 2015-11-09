import threading/Thread
import structs/Stack
import lang/Backtrace

include setjmp, assert, errno

version(windows) {
	include windows

	DebugBreak: extern func
	RaiseException: extern func (ULong, ULong, ULong, Pointer)
	IsDebuggerPresent: extern func -> Pointer
}

assert: extern func (Bool)

JmpBuf: cover from jmp_buf {
	setJmp: extern (setjmp) func -> Int
	longJmp: extern (longjmp) func (value: Int)
}

_StackFrame: cover {
	buf: JmpBuf
}

StackFrame: cover from _StackFrame* {
	new: static func -> This {
		gc_malloc(_StackFrame size)
	}
	free: func {
		gc_free(this as Void*)
	}
}

ExceptionContext: class {
	_exceptionJumpLabel := 1
	_localFrames := ThreadLocal<Stack<StackFrame>> new()
	_currentException := ThreadLocal<Exception> new()
	_stackFramesToDelete := Stack<StackFrame> new()
	exception: Exception {
		get { this _currentException get() }
		set (value) { this _currentException set(value) }
	}
	init: func
	pushStackFrame: func -> StackFrame {
		stack: Stack<StackFrame>
		if (!this _localFrames hasValue?())
			stack = Stack<StackFrame> new()
		else
			stack = this _localFrames get()
		frame := StackFrame new()
		stack push(frame)
		this _localFrames set(stack)
		frame
	}
	cleanupStackFrames: func {
		while (!this _stackFramesToDelete isEmpty)
			if ((frame := this _stackFramesToDelete pop()))
				frame free()
	}
	popStackFrame: func {
		if ((frame := this _localFrames get() pop()))
			frame free()
		this cleanupStackFrames()
	}
	takeStackFrame: func -> StackFrame {
		frame := this _localFrames get() pop()
		this _stackFramesToDelete push(frame)
		frame
	}
	hasStackFrame: func -> Bool {
		this _localFrames hasValue?() && this _localFrames get() size > 0
	}
}

exceptionContext := ExceptionContext new()

_pushStackFrame: func -> StackFrame { exceptionContext pushStackFrame() }
_popStackFrame: func -> StackFrame { exceptionContext popStackFrame() }
_getException: func -> Exception { exceptionContext exception }

version(windows) {
	import native/win32/[types, errors]

	getOSErrorCode: func -> Int {
		GetLastError()
	}
	getOSError: func -> String {
		GetWindowsErrorMessage(GetLastError())
	}
} else {
	errno: extern Int
	strerror: extern func (Int) -> CString

	getOSErrorCode: func -> Int {
		errno
	}
	getOSError: func -> String {
		x := strerror(errno)
		(x != null) ? x toString() : ""
	}
}

raise: func (message: String) {
	Exception new(message) throw()
}
raise: func ~withClass (class: Class, message: String) {
	Exception new(class, message) throw()
}

Exception: class {
	backtraces := Stack<Backtrace> new()
	origin: Class
	message : String

	addBacktrace: func {
		backtrace := BacktraceHandler get() backtrace()
		if (backtrace)
			this backtraces push(backtrace)
	}
	printBacktrace: func {
		handler := BacktraceHandler get()
		for (i in 0 .. this backtraces size)
			stderr write(handler backtraceSymbols(this backtraces peek(i)))
	}
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
	formatMessage: func -> String {
		if (this origin)
			"[%s in %s]: %s\n" format(This class name toCString(), this origin name toCString(), this message ? this message toCString() : "<no message>" toCString())
		else
			"[%s]: %s\n" format(This class name toCString(), this message ? this message toCString() : "<no message>" toCString())
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
					print()
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
		if ((message != null) && (!message empty?())) {
			message = message append(':') append(errorCode)
		} else message = errorCode
	}
}

OutOfBoundsException: class extends Exception {
	init: func (=origin, accessOffset, elementLength: SizeT) {
		init(accessOffset, elementLength)
	}
	init: func ~noOrigin (accessOffset, elementLength: SizeT) {
		message = "Trying to access an element at offset %d, but size is only %d!" format(accessOffset, elementLength)
	}
}

OutOfMemoryException: class extends Exception {
	init: func (=origin) {
		init()
	}
	init: func ~noOrigin {
		message = "Failed to allocate more memory!"
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
		stderr write(message). write('\n')
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
		stderr write(message). write('\n')
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

/* ------ C interface ------ */

include stdlib

/* stdlib.h -
 *
 * The  abort() first unblocks the SIGABRT signal, and then raises that
 * signal for the calling process.  This results in the abnormal
 * termination of the process unless the SIGABRT signal is caught
 * and the signal handler does not return (see longjmp(3)).
 *
 * If the abort() function causes process termination, all open streams
 * are closed and flushed.
 *
 * If the SIGABRT signal is ignored, or caught by a handler that returns,
 * the abort() function will still terminate the process.  It does this
 * by restoring the default disposition for SIGABRT and then raising
 * the signal for a second time.
 */
abort: extern func

version ((linux || apple) && !android) {
	include signal

	/* signal.h -
	 *
	 * This signal() facility is a simplified interface to the more general
	 * sigaction(2) facility.  Signals allow the manipulation of a process from
	 * outside its domain, as well as allowing the process to manipulate itself
	 * or copies of itself (children).
	 *
	 * There are two general types of signals: those that cause termination of
	 * a process and those that do not.  Signals which cause termination of a
	 * program might result from an irrecoverable error or might be the result
	 * of a user at a terminal typing the `interrupt' character.
	 *
	 * Signals are used when a process is stopped because it wishes to access
	 * its control terminal while in the background (see tty(4)).  Signals are
	 * optionally generated when a process resumes after being stopped, when
	 * the status of child processes changes, or when input is ready at the
	 * control terminal.
	 *
	 * Most signals result in the termination of the process receiving them, if
	 * no action is taken; some signals instead cause the process receiving
	 * them to be stopped, or are simply discarded if the process has not
	 * requested otherwise.
	 *
	 * Except for the SIGKILL and SIGSTOP signals, the signal() function allows
	 * for a signal to be caught, to be ignored, or to generate an interrupt.
	 */
	signal: extern func (sig: Int, f: Pointer) -> Pointer

	SIGHUP, SIGINT, SIGILL, SIGTRAP, SIGABRT, SIGFPE, SIGBUS,
	SIGSEGV, SIGSYS, SIGPIPE, SIGALRM, SIGTERM: extern Int
}

version (windows) {
	// Windows exception handling functions
	include windows

	SetUnhandledExceptionFilter: extern func (handler: Pointer) -> Pointer

	EXCEPTION_EXECUTE_HANDLER: extern Int

	EXCEPTION_POINTERS: extern cover {
		ExceptionRecord: EXCEPTION_RECORD*
		ContextRecord: CONTEXT*
	}

	CONTEXT: extern cover

	DWORD: cover from ULong
	EXCEPTION_RECORD: extern cover {
		ExceptionCode: DWORD
	}

	// exception codes
	EXCEPTION_ACCESS_VIOLATION, EXCEPTION_ARRAY_BOUNDS_EXCEEDED,
	EXCEPTION_BREAKPOINT, EXCEPTION_DATATYPE_MISALIGNMENT,
	EXCEPTION_FLT_DENORMAL_OPERAND, EXCEPTION_FLT_DIVIDE_BY_ZERO,
	EXCEPTION_FLT_INEXACT_RESULT, EXCEPTION_FLT_INVALID_OPERATION,
	EXCEPTION_FLT_OVERFLOW, EXCEPTION_FLT_STACK_CHECK, EXCEPTION_FLT_UNDERFLOW,
	EXCEPTION_ILLEGAL_INSTRUCTION, EXCEPTION_IN_PAGE_ERROR,
	EXCEPTION_INT_DIVIDE_BY_ZERO, EXCEPTION_INT_OVERFLOW,
	EXCEPTION_INVALID_DISPOSITION, EXCEPTION_NONCONTINUABLE_EXCEPTION,
	EXCEPTION_PRIV_INSTRUCTION, EXCEPTION_SINGLE_STEP,
	EXCEPTION_STACK_OVERFLOW: extern DWORD
}
