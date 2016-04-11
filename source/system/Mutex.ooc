/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import native/[MutexUnix, MutexWin32]

MutexType: enum {
	Safe
	Unsafe
	Global
}

Mutex: abstract class {
	lock: abstract func
	unlock: abstract func

	with: func (f: Func) {
		this lock()
		f()
		this unlock()
		(f as Closure) free(Owner Receiver)
	}
	new: static func (mutexType := MutexType Safe) -> This {
		result: This
		match (mutexType) {
			case MutexType Safe => {
				version (unix || apple)
					result = MutexUnix new()
				version (windows)
					result = MutexWin32 new()
				raise(result == null, "Unsupported platform!\n", This)
			}
			case MutexType Unsafe =>
				result = MutexUnsafe new()
			case =>
				result = MutexGlobal new()
		}
		result
	}
}

MutexUnsafe: class extends Mutex {
	init: func
	lock: override func
	unlock: override func
}

MutexGlobal: class extends Mutex {
	_globalMutex := static Mutex new(MutexType Safe)
	init: func
	lock: override func { This _globalMutex lock() }
	unlock: override func { This _globalMutex unlock() }
	free: static func ~all { This _globalMutex free() }
}

// A recursive mutex can be locked several times in a row. unlock() should be called as many times to properly unlock it
RecursiveMutex: abstract class extends Mutex {
	lock: abstract func
	unlock: abstract func

	new: static func -> This {
		result: This = null
		version (unix || apple)
			result = RecursiveMutexUnix new()
		version (windows)
			result = RecursiveMutexWin32 new()
		raise(result == null, "Unsupported platform!\n", This)
		result
	}
}
