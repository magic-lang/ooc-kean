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

import TimeSpan
import Order

DateTimeData: class {
	year: Int { get set }
	month: Int { get set }
	day: Int { get set }
	hour: Int { get set }
	minute: Int { get set }
	second: Int { get set }
	millisecond: Int { get set }
	init: func ()
}

DateTime: cover {
	/* Number of 100 ns intervals since 00.00 1/1/1 */
	_ticks: UInt64
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromYearMonthDay (year, month, day: Int) {
		if (dateIsValid(year, month, day))
			this _ticks = DateTime dateToTicks(year, month, day)
		else
			raise ("invalid input specified for constructor(year,month,day)")
	}
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) {
		if (timeIsValid(hour, minute, second, millisecond))
			this _ticks = DateTime timeToTicks(hour, minute, second, millisecond)
		else
			raise ("invalid input specified for constructor(hour,minute,second)")
	}
	init: func@ ~fromDateTime (year, month, day, hour, minute, second, millisecond: Int) {
		if (dateIsValid(year, month, day) && timeIsValid(hour, minute, second, millisecond))
			this _ticks = DateTime timeToTicks(hour, minute, second, millisecond) + DateTime dateToTicks(year, month, day)
		else
			raise ("invalid input specified for constructor(year,month,day,hour,minute,second,ms)")
	}
	isLeapYear: static func (year: Int) -> Bool { (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0) }
	kean_base_dateTime_getTicks: unmangled func -> UInt64 { this _ticks }
	new: unmangled(kean_base_dateTime_new) static func ~API (ticks: UInt64) -> This { This new(ticks) }

	millisecond: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) millisecond
	}
	second: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) second
	}
	minute: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) minute
	}
	hour: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) hour
	}
	day: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) day
	}
	month: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) month
	}
	year: func -> Int {
		DateTime _ticksToDateTimeHelper(this ticks) year
	}

	toString: func -> String {
		this toStringFormat(DateTime DefaultFormat)
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
		data := DateTime _ticksToDateTimeHelper(this ticks)
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

	compareTo: func (other: DateTime) -> Order {
		if (this ticks > other ticks)
			Order greater
		else if (this ticks < other ticks)
			Order less
		else
			Order equal
	}

	operator - (other: DateTime) -> TimeSpan {
		TimeSpan new(this ticks as Int64 - other ticks as Int64)
	}
	operator + (span: TimeSpan) -> DateTime {
		DateTime new(this ticks as Int64 + span ticks)
	}
	operator - (span: TimeSpan) -> DateTime {
		DateTime new(this ticks as Int64 - span ticks)
	}
	operator == (other: DateTime) -> Bool {
		this compareTo(other) == Order equal
	}
	operator != (other: DateTime) -> Bool {
		this compareTo(other) != Order equal
	}
	operator < (other: DateTime) -> Bool {
		this compareTo(other) == Order less
	}
	operator <= (other: DateTime) -> Bool {
		this compareTo(other) != Order greater
	}
	operator > (other: DateTime) -> Bool {
		this compareTo(other) == Order greater
	}
	operator >= (other: DateTime) -> Bool {
		this compareTo(other) != Order less
	}

	/* number of days in year ( non-leap ) */
	DaysInYear: static const Int = 365
	DaysInFourYears: static const Int = 3 * 365 + 366
	TicksPerMillisecond: static const Int64 = 1000
	TicksPerSecond: static const Int64 = TicksPerMillisecond * 1000
	TicksPerMinute: static const Int64 = TicksPerSecond * 60
	TicksPerHour: static const Int64 = TicksPerMinute * 60
	TicksPerDay: static const Int64 = TicksPerHour * 24
	TicksPerWeek: static const UInt64 = TicksPerDay * 7
	TicksPerFourYears: static const Int64 = DaysInFourYears * TicksPerDay
	/* default date/time printing format */
	DefaultFormat: static const String = "%yyyy-%MM-%dd %hh:%mm:%ss::%zzzz"

	_ticksToDateTimeHelper: static func (totalTicks: Int64) -> DateTimeData {
		result := DateTimeData new()
		fourYearBlocks := totalTicks / DateTime TicksPerFourYears
		year := 4 * fourYearBlocks
		ticksLeft := totalTicks - fourYearBlocks * DateTime TicksPerFourYears
		for (y in year + 1 .. year + 5) {
			t := DateTime ticksInYear(y)
			if (ticksLeft < t) {
				year = y
				break
			} else {
				ticksLeft -= t
			}
		}
		month := 0
		for (m in 1 .. 13) {
			t := DateTime ticksInMonth(year, m)
			if (ticksLeft < t) {
				month = m
				break
			} else {
				ticksLeft -= t
			}
		}
		days := ticksLeft / DateTime TicksPerDay
		ticksLeft -= days * DateTime TicksPerDay
		hour := ticksLeft / DateTime TicksPerHour
		ticksLeft -= hour * DateTime TicksPerHour
		minute := ticksLeft / DateTime TicksPerMinute
		ticksLeft -= minute * DateTime TicksPerMinute
		second := ticksLeft / DateTime TicksPerSecond
		ticksLeft -= second * DateTime TicksPerSecond
		millisecond := ticksLeft / DateTime TicksPerMillisecond
		result year = year
		result month = month
		result day = days + 1
		result hour = hour
		result minute = minute
		result second = second
		result millisecond = millisecond
		result
	}

	/* returns number of ticks for given hours, minutes and seconds */
	timeToTicks: static func(hours, minutes, seconds, millisecond: Int) -> Int64 {
		(hours * 3600 + minutes * 60 + seconds) * DateTime TicksPerSecond + millisecond * DateTime TicksPerMillisecond
	}

	/* returns number of ticks for given date at 0:00*/
	dateToTicks: static func(year, month, day : Int) -> UInt64 {
		if (DateTime dateIsValid(year, month, day)) {
			totalDays := day - 1
			for (m in 1 .. month) {
				totalDays += DateTime daysInMonth(year, m)
			}
			fourYearBlocks := (year - 1) / 4
			year_start := fourYearBlocks * 4
			for (y in year_start + 1 .. year)
				totalDays += DateTime daysInYear(y)
			totalDays += fourYearBlocks * DateTime DaysInFourYears
			totalDays * DateTime TicksPerDay
		} else {
			0
		}
	}

	daysInYear: static func (year: Int) -> Int {
		DateTime DaysInYear + isLeapYear(year)
	}

	ticksInYear: static func (year: Int) -> UInt64 {
		DateTime daysInYear(year) * DateTime TicksPerDay
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
		DateTime TicksPerDay * DateTime daysInMonth(year, month)
	}
	/* validate argument ranges for hour/minutes/seconds vaules */
	timeIsValid: static func (hour, minute, second, millisecond: Int) -> Bool {
		hour >= 0 && hour < 24 && minute >= 0 && minute < 60 && second >= 0 && second < 60 && millisecond >= 0 && millisecond < 1000
	}
	/* validate argument ranges for year/month/day values */
	dateIsValid: static func (year, month, day : Int) -> Bool {
		year >= 1 && month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth(year, month)
	}

}
