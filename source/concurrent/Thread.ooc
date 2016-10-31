/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdint

use base
import native/[ThreadUnix, ThreadWin32]

Thread: abstract class {
	_code: Func

	start: abstract func -> Bool
	wait: abstract func -> Bool
	wait: abstract func ~timed (seconds: Double) -> Bool
	detach: abstract func -> Bool
	cancel: abstract func -> Bool
	alive: abstract func -> Bool
	new: static func (._code) -> This {
		result: This = null
		version (unix || apple)
			result = ThreadUnix new(_code) as This
		version (windows)
			result = ThreadWin32 new(_code) as This
		Debug error(result == null, "Unsupported platform!\n", This)
		result
	}
	currentThread: static func -> This {
		result: This = null
		version (unix || apple)
			result = ThreadUnix _currentThread()
		version (windows)
			result = ThreadWin32 _currentThread()
		result
	}
	currentThreadId: static func -> ThreadId {
		result: ThreadId
		version (unix || apple)
			result = pthread_self() as ThreadId
		version (windows)
			result = GetCurrentThreadId() as ThreadId
		result
	}
	yield: static func -> Bool {
		result := false
		version (unix || apple)
			result = ThreadUnix _yield()
		version (windows)
			result = ThreadWin32 _yield()
		result
	}
}

version (unix || apple) {
	// This should be in external/pthread.ooc but fails for unknown reason
	include pthread | (_XOPEN_SOURCE=500, _POSIX_C_SOURCE=200809L)
	ThreadId: cover from PThread {
		equals: func (other: This) -> Bool {
			pthread_equal(this as PThread, other as PThread) != 0
		}
	}
}

version (windows) {
	ThreadId: cover from DWORD {
		equals: func (other: This) -> Bool {
			this == other
		}
	}
}
