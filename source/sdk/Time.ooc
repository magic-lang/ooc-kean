/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import os/win32

version(linux) {
	include unistd | (__USE_BSD), sys/time | (__USE_BSD), time | (__USE_BSD)
	//include unistd, sys/time, time
}
version(!linux) {
	include unistd, sys/time
}
version(windows) {
	include windows
}

version(windows) {
	SystemTime: cover from SYSTEMTIME {
		wYear, wMonth, wDayOfWeek, wDay, wHour, wMinute, wSecond, wMilliseconds : extern UShort
	}

	GetLocalTime: extern func (SystemTime*)
	QueryPerformanceCounter: extern func (LargeInteger*)
	QueryPerformanceFrequency: extern func (LargeInteger*)
	Sleep: extern func (UInt)

	LocaleId: cover from LCID
	LOCALE_USER_DEFAULT: extern LocaleId
	GetTimeFormat: extern func (LocaleId, Long, SystemTime*, CString, CString, Int) -> Int
	GetDateFormat: extern func (LocaleId, Long, SystemTime*, CString, CString, Int) -> Int
} else {
	TimeT: cover from time_t
	TimeZone: cover from struct timezone
	TMStruct: cover from struct tm {
		tm_sec, tm_min, tm_hour, tm_mday, tm_mon, tm_year, tm_wday, tm_yday, tm_isdst : extern Int
	}
	TimeVal: cover from struct timeval {
		tv_sec: extern TimeT
		tv_usec: extern Int
	}

	time: extern proto func (TimeT*) -> TimeT
	localtime: extern func (TimeT*) -> TMStruct*
	gettimeofday: extern func (TimeVal*, TimeZone*) -> Int
	usleep: extern func (UInt)
	_asctime: extern (asctime) func (TMStruct*) -> CString

	// An `asctime` wrapper that copies the result to a new string. Otherwise, it would be overwritten in later calls.
	asctime: func (timePtr: TMStruct*) -> String {
		cStr := _asctime(timePtr)
		String new(cStr, cStr length() - 1)
	}
}

Time: class {
	__time_microsec_base := static This runTime()
	__time_millisec_base := static This __time_microsec_base / 1000

	dateTime: static func -> String {
		result: String
		version (windows) {
			dateLength := GetDateFormat(LOCALE_USER_DEFAULT, 0, null, null, null, 0)
			dateBuffer := calloc(1, dateLength) as Char*
			GetDateFormat(LOCALE_USER_DEFAULT, 0, null, null, dateBuffer, dateLength)
			date := String new(dateBuffer, dateLength - 1)

			timeLength := GetTimeFormat(LOCALE_USER_DEFAULT, 0, null, null, null, 0)
			timeBuffer := calloc(1, timeLength) as Char*
			GetTimeFormat(LOCALE_USER_DEFAULT, 0, null, null, timeBuffer, timeLength)
			time := String new(timeBuffer, timeLength - 1)

			result = "%s %s" format(date, time)
		} else {
			tm: TimeT
			time(tm&)
			result = asctime(localtime(tm&))
		}
		result
	}

	// The microseconds that have elapsed in the current minute.
	microtime: static func -> LLong {
		return microsec() as LLong + (sec() as LLong) * 1_000_000
	}

	// The microseconds that have elapsed in the current second.
	microsec: static func -> UInt {
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			return st wMilliseconds * 1000
		} else {
			tv : TimeVal
			gettimeofday(tv&, null)
			return tv tv_usec
		}
		return -1
	}

	// The number of milliseconds elapsed since program start.
	runTime: static func -> UInt {
		version(windows) {
			// NOTE: this was previously using timeGetTime, but it's
			// a winmm.lib function and we can't afford the extra dep
			// I believe every computer that runs ooc programs on Win32
			// has a hardware high-performance counter, so it shouldn't be an issue
			counter, frequency: LargeInteger
			QueryPerformanceCounter(counter&)
			QueryPerformanceFrequency(frequency&)
			return ((counter quadPart * 1000) / frequency quadPart) - __time_millisec_base
		} else {
			return This runTimeMicro() / (1000 as UInt)
		}
		return -1
	}
	// The number of microseconds elapsed since program start.
	runTimeMicro: static func -> UInt {
		version(!windows) {
			tv : TimeVal
			gettimeofday(tv&, null)
			return ((tv tv_usec + tv tv_sec * 1_000_000) - __time_millisec_base) as UInt
		} else {
			return This runTime() * (1000 as UInt)
		}
		return -1
	}
	// The number of milliseconds spent executing 'action'
	measure: static func (action: Func) -> UInt {
		t1 := runTime()
		action()
		t2 := runTime()
		t2 - t1
	}
	// The seconds that have elapsed in the current minute.
	sec: static func -> UInt {
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			return st wSecond
		} else {
			tt := time(null)
			val := localtime(tt&)
			return val@ tm_sec
		}
		return -1
	}
	// The minutes that have elapsed in the current hour.
	min: static func -> UInt {
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			return st wMinute
		} else {
			tt := time(null)
			val := localtime(tt&)
			return val@ tm_min
		}
		return -1
	}
	// The hours that have elapsed in the current day.
	hour: static func -> UInt {
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			return st wHour
		} else {
			tt := time(null)
			val := localtime(tt&)
			return val@ tm_hour
		}
		return -1
	}
	sleepSec: static func (duration: Float) {
		sleepMicro(duration * 1_000_000)
	}
	sleepMilli: static func (duration: UInt) {
		sleepMicro(duration * 1_000)
	}
	sleepMicro: static func (duration: UInt) {
		version(windows) {
			Sleep(duration / 1_000)
		} else {
			usleep(duration)
		}
	}
}
