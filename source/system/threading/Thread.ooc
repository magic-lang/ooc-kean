/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
		if (result == null)
			Exception new(This, "Unsupported platform!\n") throw()
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
	currentThreadId: static func -> Long {
		result: Long = 0L
		version (unix || apple)
			result = pthread_self() as Long
		version (windows)
			result = GetCurrentThread() as Long
		result
	}
	equals: static func (threadId1, threadId2: Long) -> Bool {
		result: Bool
		version (unix || apple)
			result = pthread_equal(threadId1 as PThread, threadId2 as PThread) != 0
		else
			result = threadId1 == threadId2
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
