/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Time: class {
	_timeMicrosecBase := static This runTime()
	_timeMillisecBase := static This _timeMicrosecBase / 1000

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
		This microsec() + This sec() * 1_000_000LL
	}

	// The microseconds that have elapsed in the current second.
	microsec: static func -> UInt {
		result: UInt
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			result = st wMilliseconds * 1000
		} else {
			tv: TimeVal
			gettimeofday(tv&, null)
			result = tv tv_usec
		}
		result
	}
	runTime: static func -> UInt {
		result: UInt
		version(windows) {
			counter, frequency: LargeInteger
			QueryPerformanceCounter(counter&)
			QueryPerformanceFrequency(frequency&)
			result = ((counter quadPart * 1000) / frequency quadPart) - _timeMillisecBase
		} else {
			result = This runTimeMicro() / 1000U
		}
		result
	}
	runTimeMicro: static func -> UInt {
		result: UInt
		version(!windows) {
			tv: TimeVal
			gettimeofday(tv&, null)
			result = ((tv tv_usec + tv tv_sec * 1_000_000) - _timeMillisecBase) as UInt
		} else {
			result = This runTime() * 1000U
		}
		result
	}
	// The seconds that have elapsed in the current minute
	sec: static func -> UInt {
		result: UInt
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			result = st wSecond
		} else {
			tt := time(null)
			val := localtime(tt&)
			result = val@ tm_sec
		}
		result
	}
	// The minutes that have elapsed in the current hour
	min: static func -> UInt {
		result: UInt
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			result = st wMinute
		} else {
			tt := time(null)
			val := localtime(tt&)
			result = val@ tm_min
		}
		result
	}
	// The hours that have elapsed in the current day
	hour: static func -> UInt {
		result: UInt
		version(windows) {
			st: SystemTime
			GetLocalTime(st&)
			result = st wHour
		} else {
			tt := time(null)
			val := localtime(tt&)
			result = val@ tm_hour
		}
		result
	}
	sleepSec: static func (duration: Float) {
		This sleepMicro(duration * 1_000_000)
	}
	sleepMilli: static func (duration: UInt) {
		This sleepMicro(duration * 1_000)
	}
	sleepMicro: static func (duration: UInt) {
		version(windows)
			Sleep(duration / 1_000)
		else
			usleep(duration)
	}
}
