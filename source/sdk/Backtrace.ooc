import os/[Env, Dynlib]
import io/File
import structs/List
import mangling

BacktraceHandler: class {
	lib: Dynlib = null
	fancyBacktrace: Pointer
	fancyBacktraceSymbols: Pointer
	fancyBacktraceWithContext: Pointer // windows-only
	fancy := true
	raw := false

	backtrace: func -> Backtrace {
		buffer := gc_malloc(Pointer size * BACKTRACE_LENGTH)

		if (lib) {
			// use fancy-backtrace, best one!
			f := (fancyBacktrace, null) as Func (Pointer*, Int) -> Int
			length := f(buffer, BACKTRACE_LENGTH)
			return Backtrace new(buffer, length)
		} else {
			// fall back on execinfo? still informative
			version (linux || apple) {
				if (!This WARNED_ABOUT_FALLBACK) {
					stderr write("[Backtrace] Falling back on execinfo.. (build extension if you want fancy backtraces)\n")
					This WARNED_ABOUT_FALLBACK = true
				}
				length := backtrace(buffer, BACKTRACE_LENGTH)
				return Backtrace new(buffer, length)
			}

			// no such luck, use a debugger :(
			if (!This WARNED_ABOUT_FALLBACK) {
				stderr write("[Backtrace] No backtrace extension nor execinfo - use a debugger!\n")
				This WARNED_ABOUT_FALLBACK = true
			}
			gc_free(buffer)
			return null
		}
	}
	backtraceWithContext: func (contextPtr: Pointer) -> Backtrace {
		version (windows) {
			buffer := gc_malloc(Pointer size * BACKTRACE_LENGTH) as Pointer*
			f := (fancyBacktraceWithContext, null) as Func (Pointer*, Int, Pointer) -> Int
			length := f(buffer, BACKTRACE_LENGTH, contextPtr)
			return Backtrace new(buffer, length)
		}
		return null
	}
	backtraceSymbols: func (trace: Backtrace) -> String {
		lines: CString* = null
		if (lib) {
			// use fancy-backtrace
			f := (fancyBacktraceSymbols, null) as Func (Pointer*, Int) -> CString*
			lines = f(trace buffer, trace length)
			return _format(lines, trace length)
		} else {
			// fall back on execinfo
			version (linux || apple) {
				lines = backtrace_symbols(trace buffer, trace length)
				// nothing to format here, just a dumb platform-specific stack trace :/
				buffer := CharBuffer new()
				for (i in 0 .. trace length)
					buffer append(lines[i]). append('\n')
				return buffer toString()
			}
		}
		"[no backtrace]"
	}

	init: func {
		if (Env get("NO_FANCY_BACKTRACE")) {
			fancy = false
			return
		}
		if (Env get("RAW_BACKTRACE")) {
			raw = true
		}

		this lib = Dynlib load("fancy_backtrace") ?? Dynlib load("./fancy_backtrace")

		if (lib) {
			_initFuncs()
			atexit(_cleanup_backtrace)
		} else
			fancy = false
	}
	_initFuncs: func {
		if (!lib) return

		_getSymbol(fancyBacktrace&, "fancy_backtrace")
		_getSymbol(fancyBacktraceSymbols&, "fancy_backtrace_symbols")

		version (windows) {
			_getSymbol(fancyBacktraceWithContext&, "fancy_backtrace_with_context")
		}
	}
	_getSymbol: func (target: Pointer@, name: String) {
		target = lib symbol(name)
		if (!target) {
			stderr write("[Backtrace] Couldn't get %s symbol!\n" format(name))
			lib = null
		}
	}
	_format: func (lines: CString*, length: Int) -> String {
		buffer := CharBuffer new()

		if (raw) {
			buffer append("[raw backtrace]\n")
			for (i in 0 .. length)
				buffer append(lines[i]). append('\n')
			return buffer toString()
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
	BACKTRACE_LENGTH := static 128
	WARNED_ABOUT_FALLBACK := static false
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
			gc_free(this buffer)
		super()
	}
}

/*
 * Called on program exit, frees the library - absolutely necessary
 * on Win32, absolutely useless on other platforms, but doesn't hurt.
 * Sucks in any case.
 */
_cleanup_backtrace: func {
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
