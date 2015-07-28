/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
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

import DateTime
import Order
import math

TimeSpan: cover {
	_ticks: Int64
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond : Int) {
		this _ticks = DateTime timeToTicks(hour, minute, second, millisecond)
	}
	kean_base_timeSpan_getTicks: unmangled func -> Int64 { this _ticks }
	new: unmangled(kean_base_timeSpan_new) static func ~Api (ticks: UInt64) -> This { This new(ticks) }
	negate: func -> TimeSpan { TimeSpan new(-1 * this ticks) }
	elapsedMilliseconds: func -> Int64 {
		this ticks / DateTime TicksPerMillisecond
	}
	elapsedSeconds: func -> Int64 {
		this ticks / DateTime TicksPerSecond
	}
	elapsedMinutes: func -> Int64 {
		this ticks / DateTime TicksPerMinute
	}
	elapsedHours: func -> Int64 {
		this ticks / DateTime TicksPerHour
	}
	elapsedDays: func -> Int64 {
		this ticks / DateTime TicksPerDay
	}
	elapsedWeeks: func -> Int64 {
		this ticks / DateTime TicksPerWeek
	}
	operator + (value: Int) -> TimeSpan {
		TimeSpan new(this ticks + value)
	}
	operator + (value: Double) -> TimeSpan {
		this + (value * DateTime TicksPerSecond)
	}
	operator + (other: TimeSpan) -> TimeSpan {
		TimeSpan new(this ticks + other ticks)
	}
	operator - (other: TimeSpan) -> TimeSpan {
		TimeSpan new(this ticks - other ticks)
	}
	operator - (value: Double) -> TimeSpan {
		TimeSpan new(this ticks - value * DateTime TicksPerSecond)
	}
	operator - (value: Int64) -> TimeSpan {
		TimeSpan new(this ticks + value)
	}
	operator * (value: Int64) -> TimeSpan {
		TimeSpan new(this ticks * value)
	}
	compareTo: func (other: TimeSpan) -> Order {
		if (this ticks > other ticks)
			Order greater
		else if (this ticks < other ticks)
			Order less
		else
			Order equal
	}
	operator == (other: TimeSpan) -> Bool {
		this compareTo(other) == Order equal
	}
	operator != (other: TimeSpan) -> Bool {
		! (this == other)
	}
	operator > (other: TimeSpan) -> Bool {
		this compareTo(other) == Order greater
	}
	operator < (other: TimeSpan) -> Bool {
		this compareTo(other) == Order less
	}
	operator >= (other: TimeSpan) -> Bool {
		! (this < other)
	}
	operator <= (other: TimeSpan) -> Bool {
		! (this > other)
	}

	millisecond: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerMillisecond)
	}
	second: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerSecond)
	}
	minute: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerMinute)
	}
	hour: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerHour)
	}
	day: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerDay)
	}
	week: static func -> TimeSpan {
		TimeSpan new(DateTime TicksPerWeek)
	}

}
