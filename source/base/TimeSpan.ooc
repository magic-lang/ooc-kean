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

use ooc-base

TimeSpan: cover {
	_ticks: Int64
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond : Int) {
		this _ticks = DateTime timeToTicks(hour, minute, second, millisecond)
	}
	kean_base_timeSpan_getTicks: unmangled func -> Int64 { this _ticks }
	new: unmangled(kean_base_timeSpan_new) static func ~Api (ticks: Int64) -> This { This new(ticks) }
	negate: func -> This { This new(-1 * this ticks) }
	elapsedMilliseconds: func -> Int64 {
		this ticks / DateTime ticksPerMillisecond
	}
	elapsedSeconds: func -> Int64 {
		this ticks / DateTime ticksPerSecond
	}
	elapsedMinutes: func -> Int64 {
		this ticks / DateTime ticksPerMinute
	}
	elapsedHours: func -> Int64 {
		this ticks / DateTime ticksPerHour
	}
	elapsedDays: func -> Int64 {
		this ticks / DateTime ticksPerDay
	}
	elapsedWeeks: func -> Int64 {
		this ticks / DateTime ticksPerWeek
	}
	operator + (value: Int) -> This {
		This new(this ticks + value)
	}
	operator + (value: Int64) -> This {
		This new(this ticks + value)
	}
	operator + (value: Double) -> This {
		This new(this ticks + value * DateTime ticksPerSecond)
	}
	operator + (other: This) -> This {
		This new(this ticks + other ticks)
	}
	operator - (value: Int) -> This {
		This new(this ticks - value)
	}
	operator - (value: Int64) -> This {
		This new(this ticks - value)
	}
	operator - (value: Double) -> This {
		This new(this ticks - value * DateTime ticksPerSecond)
	}
	operator - (other: This) -> This {
		This new(this ticks - other ticks)
	}
	operator * (value: Int) -> This {
		This new(this ticks * value)
	}
	operator * (value: Int64) -> This {
		This new(this ticks * value)
	}
	operator * (value: Double) -> This {
		This new(this ticks * value)
	}
	compareTo: func (other: This) -> Order {
		if (this ticks > other ticks)
			Order greater
		else if (this ticks < other ticks)
			Order less
		else
			Order equal
	}
	operator == (other: This) -> Bool {
		this compareTo(other) == Order equal
	}
	operator != (other: This) -> Bool {
		! (this == other)
	}
	operator > (other: This) -> Bool {
		this compareTo(other) == Order greater
	}
	operator < (other: This) -> Bool {
		this compareTo(other) == Order less
	}
	operator >= (other: This) -> Bool {
		! (this < other)
	}
	operator <= (other: This) -> Bool {
		! (this > other)
	}

	millisecond: static func -> This {
		This new(DateTime ticksPerMillisecond)
	}
	second: static func -> This {
		This new(DateTime ticksPerSecond)
	}
	minute: static func -> This {
		This new(DateTime ticksPerMinute)
	}
	hour: static func -> This {
		This new(DateTime ticksPerHour)
	}
	day: static func -> This {
		This new(DateTime ticksPerDay)
	}
	week: static func -> This {
		This new(DateTime ticksPerWeek)
	}

}

operator + (left: Int, right: TimeSpan) -> TimeSpan { right + left }
operator + (left: Int64, right: TimeSpan) -> TimeSpan { right + left }
operator + (left: Double, right: TimeSpan) -> TimeSpan { right + left }
operator - (left: Int, right: TimeSpan) -> TimeSpan { right negate() + left }
operator - (left: Int64, right: TimeSpan) -> TimeSpan { right negate() + left }
operator - (left: Double, right: TimeSpan) -> TimeSpan { right negate() + left }
operator * (left: Int, right: TimeSpan) -> TimeSpan { right * left }
operator * (left: Int64, right: TimeSpan) -> TimeSpan { right * left }
operator * (left: Double, right: TimeSpan) -> TimeSpan { right * left }
