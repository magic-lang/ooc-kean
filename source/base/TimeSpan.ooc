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
import math

TimeSpan: cover {
	_ticks: Int64 = 0
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) {
		this _ticks = DateTime timeToTicks(hour, minute, second, millisecond)
	}
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
	defaultFormat: static const String = "%w weeks, %d days, %h hours, %m minutes, %s seconds, %z milliseconds"
	toString: func -> String {
		this toStringFormat(This defaultFormat)
	}
	// supported formatting expressions:
	//  %w - weeks (rounded down)
	//  %d - days (<7)
	//  %h - hours (<24)
	//  %m - minutes (<60)
	//  %s - seconds (<60)
	//  %z - milliseconds (<1000)	
	//  %z - milliseconds (<1000)
	//  %D - days (based on total ticks)
	//  %H - hours (based on total ticks)
	//  %M - minutes (based on total ticks)
	//  %S - seconds (based on total ticks)
	//  %Z - milliseconds (based on total ticks)	
	toStringFormat: func (format: String) -> String {
		result := format
		result = result replaceAll("%w", "%d" format(this elapsedWeeks()))
		result = result replaceAll("%D", "%d" format(this elapsedDays()))
		result = result replaceAll("%H", "%d" format(this elapsedHours()))
		result = result replaceAll("%M", "%d" format(this elapsedMinutes()))
		result = result replaceAll("%S", "%d" format(this elapsedSeconds()))
		result = result replaceAll("%Z", "%d" format(this elapsedMilliseconds()))
		result = result replaceAll("%d", "%d" format(this elapsedDays() modulo(7)))
		result = result replaceAll("%h", "%d" format(this elapsedHours() modulo(24)))
		result = result replaceAll("%m", "%d" format(this elapsedMinutes() modulo(60)))
		result = result replaceAll("%s", "%d" format(this elapsedSeconds() modulo(60)))
		result = result replaceAll("%z", "%d" format(this elapsedMilliseconds() modulo(1000)))
		result
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
	operator / (value: Int) -> This {
		This new(this ticks / value)
	}
	operator / (value: Int64) -> This {
		This new(this ticks / value)
	}
	operator / (value: Double) -> This {
		This new(this ticks / value)
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
		This milliseconds(1)
	}
	milliseconds: static func (count: Double) -> This {
		This new(DateTime ticksPerMillisecond * count)
	}
	second: static func -> This {
		This seconds(1)
	}
	seconds: static func (count: Double) -> This {
		This new(DateTime ticksPerSecond * count)
	}
	minute: static func -> This {
		This minutes(1)
	}
	minutes: static func (count: Double) -> This {
		This new(DateTime ticksPerMinute * count)
	}
	hour: static func -> This {
		This hours(1)
	}
	hours: static func (count: Double) -> This {
		This new(DateTime ticksPerHour * count)
	}
	day: static func -> This {
		This days(1)
	}
	days: static func (count: Double) -> This {
		This new(DateTime ticksPerDay * count)
	}
	week: static func -> This {
		This weeks(1)
	}
	weeks: static func (count: Double) -> This {
		This new(DateTime ticksPerWeek * count)
	}
	kean_base_timeSpan_new: unmangled static func (ticks: Int64) -> This { This new(ticks) }
	kean_base_timeSpan_fromData: unmangled static func (hour, minute, second, millisecond: Int) -> This { This new(hour, minute, second, millisecond) }
	kean_base_timeSpan_getTicks: unmangled func -> Int64 { this _ticks }
	kean_base_timeSpan_getNegated: unmangled func -> This { this negate() }
	kean_base_timeSpan_getTotalMilliseconds: unmangled func -> Int64 { this elapsedMilliseconds() }
	kean_base_timeSpan_getTotalSeconds: unmangled func -> Int64 { this elapsedSeconds() }
	kean_base_timeSpan_getTotalMinutes: unmangled func -> Int64 { this elapsedMinutes() }
	kean_base_timeSpan_getTotalHours: unmangled func -> Int64 { this elapsedHours() }
	kean_base_timeSpan_getTotalDays: unmangled func -> Int64 { this elapsedDays() }
	kean_base_timeSpan_getTotalWeeks: unmangled func -> Int64 { this elapsedWeeks() }
	kean_base_timeSpan_fromMilliseconds: unmangled static func (count: Double) -> This { This milliseconds(count) }
	kean_base_timeSpan_fromSeconds: unmangled static func (count: Double) -> This { This seconds(count) }
	kean_base_timeSpan_fromMinutes: unmangled static func (count: Double) -> This { This minutes(count) }
	kean_base_timeSpan_fromHours: unmangled static func (count: Double) -> This { This hours(count) }
	kean_base_timeSpan_fromDays: unmangled static func (count: Double) -> This { This days(count) }
	kean_base_timeSpan_fromWeeks: unmangled static func (count: Double) -> This { This weeks(count) }
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
