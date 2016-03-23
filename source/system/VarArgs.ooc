/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

__va_call: func <T> (f: Func <T> (T), T: Class, arg: T) {
	f(arg)
}

// we heard, more than once: don't use sizeof in ooc! why? because it'll
// actually be the size of the _class(), ie. the size of a pointer - which is
// what we want, so we're fine.
__sizeof: extern (sizeof) func (Class) -> SizeT

// used to align values on the pointer-size boundary, both for performance
// and to match the layout of structs
__pointer_align: func (s: SizeT) -> SizeT {
	// 'Pointer size' isn't a constant expression, but sizeof(Pointer) is.
	ps := static __sizeof(Pointer)
	diff := s % ps
	diff ? s + (ps - diff) : s
}

VarArgs: cover {
	args, argsPtr: Byte* // because the size of stuff (T size) is expressed in bytes
	count: SSizeT // number of elements

	// private api used by C code
	init: func@ (=count, bytes: SizeT) {
		this args = calloc(1, bytes + (this count * Class size))
		this argsPtr = this args
	}

	each: func (f: Func <T> (T)) {
		countdown := this count

		argsPtr := this args
		while (countdown > 0) {
			// count down!
			countdown -= 1

			// retrieve the type
			type := (argsPtr as Class*)@ as Class

			version(!windows) {
				// advance of one class size
				argsPtr += Class size
			}
			version(windows) {
				if (type size < Class size) {
					argsPtr += Class size
				} else {
					argsPtr += type size
				}
			}

			// retrieve the arg and use it
			__va_call(f, type, argsPtr@)

			// skip the size of the argument - aligned on 8 bytes, that is.
			argsPtr += __pointer_align(type size)
		}
	}

	// Internal testing method to add arguments
	_addValue: func@ <T> (value: T) {
		// store the type
		(this argsPtr as Class*)@ = T

		// advance of one class size
		this argsPtr += Class size

		// store the arg
		(this argsPtr as T*)@ = value

		// align on the pointer-size boundary
		this argsPtr += __pointer_align(T size)
	}

	iterator: func -> VarArgsIterator {
		(this args, this count, true) as VarArgsIterator
	}
}

/**
 * Can be used to iterate over variable arguments - it has more overhead
 * than each() because it involves at least one memcpy, except in a future
 * where we take advantage of generic inlining.
 */
VarArgsIterator: cover {
	argsPtr: Byte*
	countdown: SSizeT
	first: Bool

	hasNext: func -> Bool {
		this countdown > 0
	}

	// convention: argsPtr points to type of next element when called.
	next: func@ <T> (T: Class) -> T {
		if (this countdown <= 0)
			Exception new(This, "Vararg underflow!") throw()

		this countdown -= 1

		nextType := (this argsPtr as Class*)@ as Class
		result : T*
		version(!windows) {
			version (!arm) {
				result = (this argsPtr + Class size) as T*
				this argsPtr += Class size + __pointer_align(nextType size)
			}

			version (arm) {
				offset := Class size
				if (offset < nextType size) {
					offset = nextType size
				}

				result = (this argsPtr + offset) as T*
				this argsPtr += offset + __pointer_align(nextType size)
			}
		}
		version(windows) {
			if (nextType size > Class size) {
				result = (this argsPtr + nextType size) as T*
				this argsPtr += nextType size + __pointer_align(nextType size)
			} else {
				result = (this argsPtr + Class size) as T*
				this argsPtr += Class size + __pointer_align(nextType size)
			}
		}

		result@
	}

	getNextType: func@ -> Class {
		if (this countdown < 0) Exception new(This, "Vararg underflow!") throw()
		(this argsPtr as Class*)@ as Class
	}
}

include stdarg

VaList: cover from va_list
va_start: extern func (VaList, ...) // ap, last_arg
va_end: extern func (VaList) // ap
