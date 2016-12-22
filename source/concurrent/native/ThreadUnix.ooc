/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include sched
import ../Thread

sched_yield: extern func -> Int // pthread_yield is non-standard

version(unix || apple) {
ThreadUnix: class extends Thread {
	pthread: PThread

	init: func ~unix (=_code)
	start: override func -> Bool { pthread_create(this pthread&, null, this _code as Closure thunk, this _code as Closure context) == 0 }
	detach: override func -> Bool { pthread_detach(this pthread) == 0 }
	wait: override func -> Bool { pthread_join(this pthread, null) == 0 }
	wait: override func ~timed (seconds: Double) -> Bool {
		result := false
		version (apple || android)
			result = this _fakeTimedJoin(seconds)
		else {
			ts := TimeSpec fromSeconds(seconds)
			result = (pthread_timedjoin_np(this pthread, null, ts&) == 0)
		}
		result
	}
	cancel: override func -> Bool {
		result := false
		version (!android)
			result = this alive() && (pthread_cancel(this pthread) == 0)
		result
	}
	alive: override func -> Bool {
		pthread_kill(this pthread, 0) == 0
	}
	_yield: static func -> Bool {
		result := sched_yield()
		(result == 0)
	}
	_fakeTimedJoin: func (seconds: Double) -> Bool {
		result := false
		while (seconds > 0.0 && !result) {
			Time sleepMilli(20)
			seconds -= 0.02
			if (!this alive())
				result = true
		}
		result
	}
	_currentThread: static func -> This {
		thread := This new(func)
		thread pthread = pthread_self()
		thread
	}
}

version (!apple && !android) {
	// Using proto here as defining '_GNU_SOURCE' seems to cause more trouble than anything else...
	pthread_timedjoin_np: extern proto func (thread: PThread, retval: Pointer, abstime: TimeSpec*) -> Int
}
}
