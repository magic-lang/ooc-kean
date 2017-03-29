/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(linux) {
	include sys/time | (__USE_BSD, _BSD_SOURCE, _DEFAULT_SOURCE)
	include time | (__USE_BSD, _BSD_SOURCE, _DEFAULT_SOURCE)
} else {
	include sys/time
}

version(!windows) {
	TimeT: cover from time_t

	TimeZone: cover from struct timezone

	TMStruct: cover from struct tm {
		tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday, tm_yday, tm_isdst : extern Int
	}

	TimeVal: cover from struct timeval {
		tv_sec: extern TimeT
		tv_usec: extern Int
	}

	TimeSpec: cover from struct timespec {
		tv_sec: extern TimeT
		tv_nsec: extern Long

		fromSeconds: static func (seconds: Double) -> This {
			result: This
			// We need an absolute number of seconds since the epoch
			// First order of business - what time is it?
			tv: TimeVal
			gettimeofday(tv&, null)
			nowSeconds: Double = tv tv_sec as Double + tv tv_usec as Double / 1_000_000.0

			// Now compute the amount of seconds between January 1st, 1970 and the time
			// we will stop waiting on our thread
			absSeconds: Double = nowSeconds + seconds

			// And store it in a timespec, converting again...
			result tv_sec = absSeconds floor() as TimeT
			result tv_nsec = ((absSeconds -result tv_sec) * 1000 + 0.5) * (1_000_000 as Long)
			result
		}
	}

	time: extern proto func (TimeT*) -> TimeT
	localtime: extern func (TimeT*) -> TMStruct*
	gettimeofday: extern func (TimeVal*, TimeZone*) -> Int
	_asctime: extern (asctime) func (TMStruct*) -> CString

	// An `asctime` wrapper that copies the result to a new string. Otherwise, it would be overwritten in later calls.
	asctime: func (timePtr: TMStruct*) -> String {
		cStr := _asctime(timePtr)
		String new(cStr, cStr length() - 1)
	}
}
