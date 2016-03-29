/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import ../Thread

version(windows) {
ThreadWin32: class extends Thread {
	handle: Handle
	threadID: UInt

	init: func ~win (=_code)
	start: override func -> Bool {
		this handle = _beginthreadex(
			null, // default security attributes
			0, // default stack size
			this _code as Closure thunk, // thread start address
			this _code as Closure context, // argument to thread function
			0, // start thread as soon as it is created
			(this threadID)&) as Handle // returns the thread identifier

		this handle != INVALID_HANDLE_VALUE
	}
	wait: override func -> Bool {
		result := WaitForSingleObject(this handle, INFINITE)
		result == WAIT_OBJECT_0
	}
	wait: override func ~timed (seconds: Double) -> Bool {
		millis := (seconds * 1000.0 + 0.5) as Long
		result := WaitForSingleObject(this handle, millis)

		match result {
			case WAIT_TIMEOUT =>
				false // still running
			case WAIT_OBJECT_0 =>
				true // has exited!
			case =>
				// couldn't wait
				Exception new(This, "wait~timed failed with %ld" format(result as Long)) throw()
				false
		}
	}
	detach: override func -> Bool { false }
	cancel: override func -> Bool {
		false
		//this alive() && TerminateThread(this handle, 0)
		//TODO Find a better way to terminate Win32 threads, if any
	}
	alive: override func -> Bool {
		result := WaitForSingleObject(this handle, 0)
		// if it's equal, it has terminated, otherwise, it's still alive
		result != WAIT_OBJECT_0
	}
	_currentThread: static func -> This {
		thread := This new(func)
		thread handle = GetCurrentThread()
		thread
	}
	_yield: static func -> Bool {
		// I secretly curse whoever thought of this function name
		SwitchToThread()
	}
}
}
