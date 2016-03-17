/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Mutex

version(windows) {
MutexWin32: class extends Mutex {
	_backend: Handle
	init: func {
		this _backend = CreateMutex (
			null, // default security attributes
			false, // initially not owned
			null) // unnamed mutex
	}
	free: override func {
		CloseHandle(this _backend)
		super()
	}
	lock: override func {
		WaitForSingleObject(
			this _backend, // handle to mutex
			INFINITE // no time-out interval
		)
	}
	unlock: override func {
		ReleaseMutex(this _backend)
	}
}

// Win32 mutexes are recursive by default, so this is just a copy of `MutexWin32`
RecursiveMutexWin32: class extends RecursiveMutex {
	_backend: Handle
	init: func {
		this _backend = CreateMutex (
			null, // default security attributes
			false, // initially not owned
			null) // unnamed mutex
	}
	free: override func {
		CloseHandle(this _backend)
		super()
	}
	lock: override func {
		WaitForSingleObject(
			this _backend, // handle to mutex
			INFINITE // no time-out interval
		)
	}
	unlock: override func {
		ReleaseMutex(this _backend)
	}
}
}
