/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

DateTimeData: cover {
	year: Int { get set }
	month: Int { get set }
	day: Int { get set }
	hour: Int { get set }
	minute: Int { get set }
	second: Int { get set }
	millisecond: Int { get set }
	init: func@
	init: func@ ~fromDateTime (=year, =month, =day, =hour, =minute, =second, =millisecond)
}

extend Time {
	currentDateTime: static func -> DateTime {
		result: DateTime
		version(windows) {
				st: SystemTime
				GetLocalTime(st&)
				result = DateTime new(st wYear, st wMonth, st wDay, st wHour, st wMinute, st wSecond, st wMilliseconds)
		} else {
				tt := time(null)
				val := localtime(tt&)
				result = DateTime new(val@ tm_year + 1900, val@ tm_mon + 1, val@ tm_mday, val@ tm_hour, val@ tm_min, val@ tm_sec, 0)
		}
		result
	}
}

DateTime: cover {
	/* Number of 100 ns intervals since 00.00 1/1/1 */
	_ticks: ULong = 0
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromYearMonthDay (year, month, day: Int) {
		if (This dateIsValid(year, month, day))
			this _ticks = This dateToTicks(year, month, day)
		else
			raise ("invalid input specified for constructor(year,month,day)")
	}
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) {
		if (This timeIsValid(hour, minute, second, millisecond))
			this _ticks = This timeToTicks(hour, minute, second, millisecond)
		else
			raise ("invalid input specified for constructor(hour,minute,second)")
	}
	init: func@ ~fromDateTime (year, month, day, hour, minute, second, millisecond: Int) {
		if (This dateIsValid(year, month, day) && This timeIsValid(hour, minute, second, millisecond))
			this _ticks = This dateToTicks(year, month, day) + This timeToTicks(hour, minute, second, millisecond)
		else
			raise ("invalid input specified for constructor(year,month,day,hour,minute,second,ms)")
	}

	millisecond: func -> Int { This _ticksToDateTimeHelper(this ticks) millisecond }
	second: func -> Int { This _ticksToDateTimeHelper(this ticks) second }
	minute: func -> Int { This _ticksToDateTimeHelper(this ticks) minute }
	hour: func -> Int { This _ticksToDateTimeHelper(this ticks) hour }
	day: func -> Int { This _ticksToDateTimeHelper(this ticks) day }
	month: func -> Int { This _ticksToDateTimeHelper(this ticks) month }
	year: func -> Int { This _ticksToDateTimeHelper(this ticks) year }

	// Supported formatting expressions:
	//	%yyyy - year
	//	%yy	- year as two digit number
	//  %MM - month with leading zero
	//	%M	- month without leading zero
	//	%dd - day with leading zero
	//	%d	- day without leading zero
	//	%hh - hour
	//	%mm - minute
	//	%ss - second
	//	%zzz - millisecond
	toString: func (format := This defaultFormat) -> String {
		data := This _ticksToDateTimeHelper(this ticks)
		(year4String, year2String, yearString) := ("%04d" format(data year), "%02d" format(data year % 100), "%d" format(data year))
		(month2String, monthString, day2String, dayString) := ("%02d" format(data month), "%d" format(data month), "%02d" format(data day), "%d" format(data day))
		(hour2String, minute2String, second2String) := ("%02d" format(data hour), "%02d" format(data minute), "%02d" format(data second))
		(hourString, minuteString, secondString) := ("%d" format(data hour), "%d" format(data minute), "%d" format(data second))
		(millisecond3String, millisecondString) := ("%03d" format(data millisecond), "%d" format(data millisecond))
		result := format replaceAll("%yyyy", year4String)
		result = result replaceAll("%yy", year2String, true, true)
		result = result replaceAll("%y", yearString, true, true)
		result = result replaceAll("%MM", month2String, true, true)
		result = result replaceAll("%dd", day2String, true, true)
		result = result replaceAll("%M", monthString, true, true)
		result = result replaceAll("%d", dayString, true, true)
		result = result replaceAll("%hh", hour2String, true, true)
		result = result replaceAll("%mm", minute2String, true, true)
		result = result replaceAll("%ss", second2String, true, true)
		result = result replaceAll("%h", hourString, true, true)
		result = result replaceAll("%m", minuteString, true, true)
		result = result replaceAll("%s", secondString, true, true)
		result = result replaceAll("%zzz", millisecond3String, true, true)
		result = result replaceAll("%z", millisecondString, true, true)
		(year4String, year2String, yearString, month2String, monthString, day2String, dayString, hour2String, minute2String, second2String, hourString, minuteString, secondString, millisecond3String, millisecondString) free()
		result
	}
	compareTo: func (other: This) -> Order {
		if (this ticks > other ticks)
			Order Greater
		else if (this ticks < other ticks)
			Order Less
		else
			Order Equal
	}
	toNanoseconds: func -> ULong { this _ticks * This nanosecondsPerTick }

	operator - (other: This) -> TimeSpan { TimeSpan new(this ticks as Long - other ticks as Long) }
	operator == (other: This) -> Bool { this compareTo(other) == Order Equal }
	operator != (other: This) -> Bool { this compareTo(other) != Order Equal }
	operator < (other: This) -> Bool { this compareTo(other) == Order Less }
	operator <= (other: This) -> Bool { this compareTo(other) != Order Greater }
	operator > (other: This) -> Bool { this compareTo(other) == Order Greater }
	operator >= (other: This) -> Bool { this compareTo(other) != Order Less }
	operator + (span: TimeSpan) -> This { This new(this ticks as Long + span ticks) }
	operator - (span: TimeSpan) -> This { This new(this ticks as Long - span ticks) }

	daysPerYear: static Int = 365
	daysPerFourYears: static Int = 3 * This daysPerYear + 366
	nanosecondsPerTick: static Long = 100
	ticksPerMicrosecond: static Long = 1_000 / This nanosecondsPerTick
	ticksPerMillisecond: static Long = 1_000_000 / This nanosecondsPerTick
	ticksPerSecond: static Long = This ticksPerMillisecond * 1000
	ticksPerMinute: static Long = This ticksPerSecond * 60
	ticksPerHour: static Long = This ticksPerMinute * 60
	ticksPerDay: static Long = This ticksPerHour * 24
	ticksPerWeek: static Long = This ticksPerDay * 7
	ticksPerFourYears: static Long = This daysPerFourYears * This ticksPerDay
	defaultFormat: static String = "%yyyy-%MM-%dd %hh:%mm:%ss::%zzz"
	now ::= static Time currentDateTime()

	isLeapYear: static func (year: Int) -> Bool { (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0) }
	_ticksToDateTimeHelper: static func (totalTicks: Long) -> DateTimeData {
		fourYearBlocks := totalTicks / This ticksPerFourYears
		year := 4 * fourYearBlocks
		ticksLeft := totalTicks - fourYearBlocks * This ticksPerFourYears
		for (y in year + 1 .. year + 5) {
			t := This ticksInYear(y)
			if (ticksLeft < t) {
				year = y
				break
			} else
				ticksLeft -= t
		}
		month := 0
		for (m in 1 .. 13) {
			t := This ticksInMonth(year, m)
			if (ticksLeft < t) {
				month = m
				break
			} else
				ticksLeft -= t
		}
		days := ticksLeft / This ticksPerDay
		ticksLeft -= days * This ticksPerDay
		hour := ticksLeft / This ticksPerHour
		ticksLeft -= hour * This ticksPerHour
		minute := ticksLeft / This ticksPerMinute
		ticksLeft -= minute * This ticksPerMinute
		second := ticksLeft / This ticksPerSecond
		ticksLeft -= second * This ticksPerSecond
		millisecond := ticksLeft / This ticksPerMillisecond
		DateTimeData new(year, month, days + 1, hour, minute, second, millisecond)
	}
	/* returns number of ticks for given hours, minutes and seconds */
	timeToTicks: static func (hours, minutes, seconds, millisecond: Int) -> Long {
		(hours * 3600 + minutes * 60 + seconds) * This ticksPerSecond + millisecond * This ticksPerMillisecond
	}
	/* returns number of ticks for given date at 0:00*/
	dateToTicks: static func (year, month, day: Int) -> ULong {
		result := 0 as ULong
		if (This dateIsValid(year, month, day)) {
			totalDays := day - 1
			for (m in 1 .. month)
				totalDays += This daysInMonth(year, m)
			fourYearBlocks := (year - 1) / 4
			startYear := fourYearBlocks * 4
			for (y in startYear + 1 .. year)
				totalDays += This daysInYear(y)
			totalDays += fourYearBlocks * This daysPerFourYears
			result = totalDays * This ticksPerDay
		}
		result
	}
	daysInYear: static func (year: Int) -> Int {
		This daysPerYear + This isLeapYear(year)
	}
	ticksInYear: static func (year: Int) -> ULong {
		This daysInYear(year) * This ticksPerDay
	}
	daysInMonth: static func (year, month: Int) -> Int {
		if (month == 2)
			This isLeapYear(year) ? 29 : 28
		else if (month <= 7)
			month % 2 ? 31 : 30
		else
			month % 2 ? 30 : 31
	}
	ticksInMonth: static func (year, month: Int) -> ULong {
		This ticksPerDay * This daysInMonth(year, month)
	}
	timeIsValid: static func (hour, minute, second, millisecond: Int) -> Bool {
		hour in(0 .. 24) && minute in(0 .. 60) && second in(0 .. 60) && millisecond in(0 .. 1000)
	}
	dateIsValid: static func (year, month, day: Int) -> Bool {
		year >= 1 && month in(1 .. 13) && day in(1 .. This daysInMonth(year, month) + 1)
	}
	nanoseconds: static func (nanoseconds: ULong) -> This {
		This new(nanoseconds / This nanosecondsPerTick)
	}
}
