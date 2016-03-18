/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
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
