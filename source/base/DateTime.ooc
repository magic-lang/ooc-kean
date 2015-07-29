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

DateTime: cover {
	/* Number of 100 ns intervals since 00.00 1/1/1 */
	_ticks: UInt64
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromYearMonthDay (year, month, day: Int) {
		if (dateIsValid(year, month, day))
			this _ticks = This dateToTicks(year, month, day)
		else
			raise ("invalid input specified for constructor(year,month,day)")
	}
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) {
		if (timeIsValid(hour, minute, second, millisecond))
			this _ticks = This timeToTicks(hour, minute, second, millisecond)
		else
			raise ("invalid input specified for constructor(hour,minute,second)")
	}
	init: func@ ~fromDateTime (year, month, day, hour, minute, second, millisecond: Int) {
		if (dateIsValid(year, month, day) && timeIsValid(hour, minute, second, millisecond))
			this _ticks = This timeToTicks(hour, minute, second, millisecond) + This dateToTicks(year, month, day)
		else
			raise ("invalid input specified for constructor(year,month,day,hour,minute,second,ms)")
	}
	isLeapYear: static func (year: Int) -> Bool { (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0) }
	kean_base_dateTime_getTicks: unmangled func -> UInt64 { this _ticks }
	new: unmangled(kean_base_dateTime_new) static func ~API (ticks: UInt64) -> This { This new(ticks) }

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
		result = result replaceAll("%yy", "%d" format(data year % 100))
		result = result replaceAll("%MM", (data month < 10 ? "0%d" : "%d") format(data month))
		result = result replaceAll("%dd", (data day < 10 ? "0%d" : "%d") format(data day))
		result = result replaceAll("%M", "%d" format(data month))
		result = result replaceAll("%d", "%d" format(data day))
		result = result replaceAll("%hh", "%d" format(data hour))
		result = result replaceAll("%mm", "%d" format(data minute))
		result = result replaceAll("%ss", "%d" format(data second))
		result = result replaceAll("%zzzz", "%d" format(data millisecond))
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
	ticksPerMillisecond: static const Int64 = 1000
	ticksPerSecond: static const Int64 = This ticksPerMillisecond * 1000
	ticksPerMinute: static const Int64 = This ticksPerSecond * 60
	ticksPerHour: static const Int64 = This ticksPerMinute * 60
	ticksPerDay: static const Int64 = This ticksPerHour * 24
	ticksPerWeek: static const UInt64 = This ticksPerDay * 7
	ticksPerFourYears: static const Int64 = This daysPerFourYears * This ticksPerDay
	/* default date/time printing format */
	defaultFormat: static const String = "%yyyy-%MM-%dd %hh:%mm:%ss::%zzzz"

	now: static DateTime {
		get {
					data := Time dateTimeData()
					DateTime new(data year, data month, data day, data hour, data minute, data second, data millisecond)
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
	dateToTicks: static func(year, month, day : Int) -> UInt64 {
		if (This dateIsValid(year, month, day)) {
			totalDays := day - 1
			for (m in 1 .. month) {
				totalDays += This daysInMonth(year, m)
			}
			fourYearBlocks := (year - 1) / 4
			year_start := fourYearBlocks * 4
			for (y in year_start + 1 .. year)
				totalDays += This daysInYear(y)
			totalDays += fourYearBlocks * This daysPerFourYears
			totalDays * This ticksPerDay
		} else {
			0
		}
	}

	daysInYear: static func (year: Int) -> Int {
		This daysPerYear + isLeapYear(year)
	}

	ticksInYear: static func (year: Int) -> UInt64 {
		This daysInYear(year) * This ticksPerDay
	}

	daysInMonth: static func (year, month: Int) -> Int {
		if (month == 2)
			isLeapYear(year) ? 29 : 28
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
		hour >= 0 && hour < 24 && minute >= 0 && minute < 60 && second >= 0 && second < 60 && millisecond >= 0 && millisecond < 1000
	}
	/* validate argument ranges for year/month/day values */
	dateIsValid: static func (year, month, day: Int) -> Bool {
		year >= 1 && month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month)
	}

}
