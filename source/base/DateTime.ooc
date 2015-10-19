/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
import os/Time

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
		result := DateTime new(0)
		version(windows) {
				st: SystemTime
				GetLocalTime(st&)
				result = DateTime new(st wYear, st wMonth, st wDay, st wHour, st wMinute, st wSecond, st wMilliseconds)
		}
		version(!windows) {
				tt := time(null)
				val := localtime(tt&)
				result = DateTime new(val@ tm_year + 1900, val@ tm_mon + 1, val@ tm_mday, val@ tm_hour, val@ tm_min, val@ tm_sec, 0)
		}
		return result
	}
}

DateTime: cover {
	/* Number of 100 ns intervals since 00.00 1/1/1 */
	_ticks: UInt64 = 0
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
	isLeapYear: static func (year: Int) -> Bool { (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0) }
	kean_base_dateTime_getTicks: unmangled func -> UInt64 { this _ticks }
	kean_base_dateTime_new: unmangled static func (ticks: UInt64) -> This { This new(ticks) }

	millisecond: func -> Int {
		This _ticksToDateTimeHelper(this ticks) millisecond
	}
	second: func -> Int {
		This _ticksToDateTimeHelper(this ticks) second
	}
	minute: func -> Int {
		This _ticksToDateTimeHelper(this ticks) minute
	}
	hour: func -> Int {
		This _ticksToDateTimeHelper(this ticks) hour
	}
	day: func -> Int {
		This _ticksToDateTimeHelper(this ticks) day
	}
	month: func -> Int {
		This _ticksToDateTimeHelper(this ticks) month
	}
	year: func -> Int {
		This _ticksToDateTimeHelper(this ticks) year
	}

	toString: func -> String {
		this toStringFormat(This defaultFormat)
	}
	// <summary>
	// Convert this object to string representation
	// </summary>
	// supported formatting expressions:
	//	%yyyy - year
	//	%yy	- year as two digit number
	//  %MM - month with leading zero
	//	%M	- month without leading zero
	//	%dd - day with leading zero
	//	%d	- day without leading zero
	//	%hh - hour
	//	%mm - minute
	//	%ss - second
	//	%zzzz - millisecond
	// <param name="format">output format specification</param>
	toStringFormat: func (format: String) -> String {
		result := format
		data := This _ticksToDateTimeHelper(this ticks)
		result = result replaceAll("%yyyy", "%d" format(data year))
		result = result replaceAll("%yy", "%02d" format(data year % 100))
		result = result replaceAll("%MM", "%02d" format(data month))
		result = result replaceAll("%dd", "%02d" format(data day))
		result = result replaceAll("%M", "%d" format(data month))
		result = result replaceAll("%d", "%d" format(data day))
		result = result replaceAll("%hh", "%02d" format(data hour))
		result = result replaceAll("%mm", "%02d" format(data minute))
		result = result replaceAll("%ss", "%02d" format(data second))
		result = result replaceAll("%h", "%d" format(data hour))
		result = result replaceAll("%m", "%d" format(data minute))
		result = result replaceAll("%s", "%d" format(data second))
		result = result replaceAll("%zzz", "%03d" format(data millisecond))
		result = result replaceAll("%z", "%d" format(data millisecond))
		result
	}

	compareTo: func (other: This) -> Order {
		if (this ticks > other ticks)
			Order greater
		else if (this ticks < other ticks)
			Order less
		else
			Order equal
	}

	operator - (other: This) -> TimeSpan {
		TimeSpan new(this ticks as Int64 - other ticks as Int64)
	}
	operator + (span: TimeSpan) -> This {
		This new(this ticks as Int64 + span ticks)
	}
	operator - (span: TimeSpan) -> This {
		This new(this ticks as Int64 - span ticks)
	}
	operator == (other: This) -> Bool {
		this compareTo(other) == Order equal
	}
	operator != (other: This) -> Bool {
		this compareTo(other) != Order equal
	}
	operator < (other: This) -> Bool {
		this compareTo(other) == Order less
	}
	operator <= (other: This) -> Bool {
		this compareTo(other) != Order greater
	}
	operator > (other: This) -> Bool {
		this compareTo(other) == Order greater
	}
	operator >= (other: This) -> Bool {
		this compareTo(other) != Order less
	}

	/* number of days in year ( non-leap ) */
	daysPerYear: static const Int = 365
	daysPerFourYears: static const Int = 3 * This daysPerYear + 366
	nanosecondsPerTick: static const Int64 = 100
	ticksPerMillisecond: static const Int64 = 1_000_000 / This nanosecondsPerTick
	ticksPerSecond: static const Int64 = This ticksPerMillisecond * 1000
	ticksPerMinute: static const Int64 = This ticksPerSecond * 60
	ticksPerHour: static const Int64 = This ticksPerMinute * 60
	ticksPerDay: static const Int64 = This ticksPerHour * 24
	ticksPerWeek: static const UInt64 = This ticksPerDay * 7
	ticksPerFourYears: static const Int64 = This daysPerFourYears * This ticksPerDay
	/* default date/time printing format */
	defaultFormat: static const String = "%yyyy-%MM-%dd %hh:%mm:%ss::%zzzz"

	now: static This {
		get {
			Time currentDateTime()
		}
	}

	_ticksToDateTimeHelper: static func (totalTicks: Int64) -> DateTimeData {
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
	timeToTicks: static func (hours, minutes, seconds, millisecond: Int) -> Int64 {
		(hours * 3600 + minutes * 60 + seconds) * This ticksPerSecond + millisecond * This ticksPerMillisecond
	}

	/* returns number of ticks for given date at 0:00*/
	dateToTicks: static func (year, month, day: Int) -> UInt64 {
		result := 0 as UInt64
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
		return result
	}

	daysInYear: static func (year: Int) -> Int {
		This daysPerYear + This isLeapYear(year)
	}

	ticksInYear: static func (year: Int) -> UInt64 {
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

	ticksInMonth: static func (year, month: Int) -> UInt64 {
		This ticksPerDay * This daysInMonth(year, month)
	}
	/* validate argument ranges for hour/minutes/seconds vaules */
	timeIsValid: static func (hour, minute, second, millisecond: Int) -> Bool {
		hour in?(0 .. 24) && minute in?(0 .. 60) && second in?(0 .. 60) && millisecond in?(0 .. 1000)
	}
	/* validate argument ranges for year/month/day values */
	dateIsValid: static func (year, month, day: Int) -> Bool {
		year >= 1 && month in?(1 .. 13) && day in?(1 .. This daysInMonth(year, month) + 1)
	}
}
