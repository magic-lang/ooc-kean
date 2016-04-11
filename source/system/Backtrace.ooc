/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/File
import mangling

BacktraceHandler: class {
	lib: Dynlib = null
	fancyBacktrace: Pointer
	fancyBacktraceSymbols: Pointer
	fancyBacktraceWithContext: Pointer // windows-only
	fancy := true
	raw := false

	backtrace: func -> Backtrace {
		buffer := calloc(backtraceLength, Pointer size)
		result: Backtrace = null
		if (this lib) {
			// use fancy-backtrace, best one!
			f := (this fancyBacktrace, null) as Func (Pointer*, Int) -> Int
			length := f(buffer, backtraceLength)
			result = Backtrace new(buffer, length)
		} else {
			// fall back on execinfo? still informative
			version (linux || apple) {
				if (!This warnedAboutFallback) {
					stderr write("[Backtrace] Falling back on execinfo.. (build extension if you want fancy backtraces)\n")
					This warnedAboutFallback = true
				}
				length := backtrace(buffer, backtraceLength)
				result = Backtrace new(buffer, length)
			} else {
				// no such luck, use a debugger :(
				if (!This warnedAboutFallback) {
					stderr write("[Backtrace] No backtrace extension nor execinfo - use a debugger!\n")
					This warnedAboutFallback = true
				}
				memfree(buffer)
			}
		}
		result
	}
	backtraceWithContext: func (contextPtr: Pointer) -> Backtrace {
		result: Backtrace = null
		version (windows) {
			buffer := calloc(backtraceLength, Pointer size) as Pointer*
			f := (this fancyBacktraceWithContext, null) as Func (Pointer*, Int, Pointer) -> Int
			length := f(buffer, backtraceLength, contextPtr)
			result = Backtrace new(buffer, length)
		}
		result
	}
	backtraceSymbols: func (trace: Backtrace) -> String {
		lines: CString* = null
		result: String
		if (this lib) {
			// use fancy-backtrace
			f := (this fancyBacktraceSymbols, null) as Func (Pointer*, Int) -> CString*
			lines = f(trace buffer, trace length)
			result = this _format(lines, trace length)
		} else {
			// fall back on execinfo
			version (linux || apple) {
				lines = backtrace_symbols(trace buffer, trace length)
				// nothing to format here, just a dumb platform-specific stack trace :/
				buffer := CharBuffer new()
				for (i in 0 .. trace length)
					buffer append(lines[i]) . append('\n')
				result = buffer toString()
			} else
				result = "[no backtrace]"
		}
		result
	}

	init: func {
		if (Env get("NO_FANCY_BACKTRACE")) {
			this fancy = false
		} else {
			if (Env get("RAW_BACKTRACE"))
				this raw = true

			this lib = Dynlib load("fancy_backtrace") ?? Dynlib load("./fancy_backtrace")

			if (this lib) {
				this _initFuncs()
				atexit(cleanupBacktrace)
			} else
				this fancy = false
		}
	}
	_initFuncs: func {
		if (this lib) {
			this _getSymbol(this fancyBacktrace&, "fancy_backtrace")
			this _getSymbol(this fancyBacktraceSymbols&, "fancy_backtrace_symbols")
			version (windows)
				this _getSymbol(this fancyBacktraceWithContext&, "fancy_backtrace_with_context")
		}
	}
	_getSymbol: func (target: Pointer@, name: String) {
		target = this lib symbol(name)
		if (!target) {
			stderr write("[Backtrace] Couldn't get %s symbol!\n" format(name))
			this lib = null
		}
	}
	_format: func (lines: CString*, length: Int) -> String {
		buffer := CharBuffer new()

		if (this raw) {
			buffer append("[raw backtrace]\n")
			for (i in 0 .. length)
				buffer append(lines[i]) . append('\n')
			buffer toString()
		}

		buffer append("[fancy backtrace]\n")
		frameno := 0
		elements := VectorList<TraceElement> new()

		for (i in 0 .. length) {
			line := lines[i] toString()
			tokens := line split('|') map(|x| x trim())

			if (tokens count <= 4) {
				if (tokens count >= 2) {
					binary := tokens[0]
					file := "(from %s)" format(binary)
					symbol := tokens[2]
					if (symbol size >= 30) {
						symbol = "..." + symbol substring(symbol size - 30)
					}
					elements add(TraceElement new(frameno, symbol, "", file))
				}
			} else {
				filename := tokens[3]
				lineno := tokens[4]

				mangled := tokens[2]
				fullSymbol := Demangler demangle(mangled)
				package := "in %s" format(fullSymbol package)
				fullName := "%s()" format(fullSymbol fullName)
				file := "(at %s:%s)" format(filename, lineno)
				elements add(TraceElement new(frameno, fullName, package, file))
			}
			frameno += 1
		}

		maxSymbolSize := 0
		maxPackageSize := 0
		maxFileSize := 0
		for (elem in elements) {
			if (elem symbol size > maxSymbolSize)
				maxSymbolSize = elem symbol size
			if (elem package size > maxPackageSize)
				maxPackageSize = elem package size
			if (elem file size > maxFileSize)
				maxFileSize = elem file size
		}

		for (elem in elements) {
			buffer append("%s  %s  %s  %s\n" format(
				TraceElement pad(elem frameno toString(), 4),
				TraceElement pad(elem symbol, maxSymbolSize),
				TraceElement pad(elem package, maxPackageSize),
				TraceElement pad(elem file, maxFileSize)
			))
		}
		buffer toString()
	}
	backtraceLength := static 128
	warnedAboutFallback := static false
	instance: static This
	get: static func -> This {
		if (!instance)
			instance = This new()
		instance
	}
}

TraceElement: class {
	frameno: Int
	symbol, package, file: String
	init: func (=frameno, =symbol, =package, =file)
	pad: static func (s: String, length: Int) -> String {
		if (s size < length) {
			b := CharBuffer new()
			b append(s)
			for (i in (s size) .. length)
				b append(' ')
			return b toString()
		}
		s
	}
}

Backtrace: class {
	buffer: Pointer*
	length: Int

	init: func (=buffer, =length)
	free: override func {
		if (this buffer)
			memfree(this buffer)
		super()
	}
}

cleanupBacktrace: func {
	h := BacktraceHandler get()
	if (h lib)
		h lib close()
}

version ((linux || apple) && !android) {
	include execinfo

	backtrace: extern func (array: Void**, size: Int) -> Int
	backtrace_symbols: extern func (
		array: Pointer*, size: Int) -> CString*
	backtrace_symbols_fd: extern func (
		array: Pointer*, size: Int, fd: Int)
}
