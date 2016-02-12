/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

TimeSpan: cover {
	_ticks: Long = 0
	ticks ::= this _ticks
	init: func@ (=_ticks)
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) {
		this _ticks = DateTime timeToTicks(hour, minute, second, millisecond)
	}
	negate: func -> This { This new(-this ticks) }
	toNanoseconds: func -> Long { this ticks * DateTime nanosecondsPerTick }
	toMilliseconds: func -> Long { this ticks / DateTime ticksPerMillisecond }
	toSeconds: func -> Long { this ticks / DateTime ticksPerSecond }
	toMinutes: func -> Long { this ticks / DateTime ticksPerMinute }
	toHours: func -> Long { this ticks / DateTime ticksPerHour }
	toDays: func -> Long { this ticks / DateTime ticksPerDay }
	toWeeks: func -> Long { this ticks / DateTime ticksPerWeek }

	defaultFormat: static Text = t"%w weeks, %d days, %h hours, %m minutes, %s seconds, %z milliseconds"
	// supported formatting expressions:
	//  %w - weeks (rounded down)
	//  %d - days (<7)
	//  %h - hours (<24)
	//  %m - minutes (<60)
	//  %s - seconds (<60)
	//  %z - milliseconds (<1000)
	//  %D - days (based on total ticks)
	//  %H - hours (based on total ticks)
	//  %M - minutes (based on total ticks)
	//  %S - seconds (based on total ticks)
	//  %Z - milliseconds (based on total ticks)
	toText: func (format := This defaultFormat) -> Text {
		result := format copy()
		result = result replaceAll(t"%w", t"%d" format(this toWeeks()))
		result = result replaceAll(t"%D", t"%d" format(this toDays()))
		result = result replaceAll(t"%H", t"%d" format(this toHours()))
		result = result replaceAll(t"%M", t"%d" format(this toMinutes()))
		result = result replaceAll(t"%S", t"%d" format(this toSeconds()))
		result = result replaceAll(t"%Z", t"%d" format(this toMilliseconds()))
		result = result replaceAll(t"%d", t"%d" format(this toDays() modulo(7)))
		result = result replaceAll(t"%h", t"%d" format(this toHours() modulo(24)))
		result = result replaceAll(t"%m", t"%d" format(this toMinutes() modulo(60)))
		result = result replaceAll(t"%s", t"%d" format(this toSeconds() modulo(60)))
		result replaceAll(t"%z", t"%d" format(this toMilliseconds() modulo(1000)))
	}
	compareTo: func (other: This) -> Order {
		if (this ticks > other ticks)
			Order greater
		else if (this ticks < other ticks)
			Order less
		else
			Order equal
	}

	operator + (other: This) -> This { This new(this ticks + other ticks) }
	operator - (other: This) -> This { This new(this ticks - other ticks) }
	operator == (other: This) -> Bool { this compareTo(other) == Order equal }
	operator != (other: This) -> Bool { !(this == other) }
	operator > (other: This) -> Bool { this compareTo(other) == Order greater }
	operator < (other: This) -> Bool { this compareTo(other) == Order less }
	operator >= (other: This) -> Bool { !(this < other) }
	operator <= (other: This) -> Bool { !(this > other) }
	operator + (value: Int) -> This { This new(this ticks + value) }
	operator - (value: Int) -> This { This new(this ticks - value) }
	operator * (value: Int) -> This { This new(this ticks * value) }
	operator / (value: Int) -> This { This new(this ticks / value) }
	operator + (value: Long) -> This { This new(this ticks + value) }
	operator - (value: Long) -> This { This new(this ticks - value) }
	operator * (value: Long) -> This { This new(this ticks * value) }
	operator / (value: Long) -> This { This new(this ticks / value) }
	operator + (value: Double) -> This { This new(this ticks + value * DateTime ticksPerSecond) }
	operator - (value: Double) -> This { This new(this ticks - value * DateTime ticksPerSecond) }
	operator * (value: Double) -> This { This new(this ticks * value) }
	operator / (value: Double) -> This { This new(this ticks / value) }

	kean_base_timeSpan_getTicks: unmangled func -> Long { this _ticks }
	kean_base_timeSpan_getNegated: unmangled func -> This { this negate() }
	kean_base_timeSpan_getTotalMilliseconds: unmangled func -> Long { this toMilliseconds() }
	kean_base_timeSpan_getTotalSeconds: unmangled func -> Long { this toSeconds() }
	kean_base_timeSpan_getTotalMinutes: unmangled func -> Long { this toMinutes() }
	kean_base_timeSpan_getTotalHours: unmangled func -> Long { this toHours() }
	kean_base_timeSpan_getTotalDays: unmangled func -> Long { this toDays() }
	kean_base_timeSpan_getTotalWeeks: unmangled func -> Long { this toWeeks() }

	millisecond: static func -> This { This milliseconds(1) }
	second: static func -> This { This seconds(1) }
	minute: static func -> This { This minutes(1) }
	hour: static func -> This { This hours(1) }
	day: static func -> This { This days(1) }
	week: static func -> This { This weeks(1) }

	milliseconds: static func (count: Double) -> This { This new(DateTime ticksPerMillisecond * count) }
	seconds: static func (count: Double) -> This { This new(DateTime ticksPerSecond * count) }
	minutes: static func (count: Double) -> This { This new(DateTime ticksPerMinute * count) }
	hours: static func (count: Double) -> This { This new(DateTime ticksPerHour * count) }
	days: static func (count: Double) -> This { This new(DateTime ticksPerDay * count) }
	weeks: static func (count: Double) -> This { This new(DateTime ticksPerWeek * count) }

	kean_base_timeSpan_new: unmangled static func (ticks: Long) -> This { This new(ticks) }
	kean_base_timeSpan_fromData: unmangled static func (hour, minute, second, millisecond: Int) -> This { This new(hour, minute, second, millisecond) }
	kean_base_timeSpan_fromMilliseconds: unmangled static func (count: Double) -> This { This milliseconds(count) }
	kean_base_timeSpan_fromSeconds: unmangled static func (count: Double) -> This { This seconds(count) }
	kean_base_timeSpan_fromMinutes: unmangled static func (count: Double) -> This { This minutes(count) }
	kean_base_timeSpan_fromHours: unmangled static func (count: Double) -> This { This hours(count) }
	kean_base_timeSpan_fromDays: unmangled static func (count: Double) -> This { This days(count) }
	kean_base_timeSpan_fromWeeks: unmangled static func (count: Double) -> This { This weeks(count) }
}

operator + (left: Int, right: TimeSpan) -> TimeSpan { right + left }
operator - (left: Int, right: TimeSpan) -> TimeSpan { right negate() + left }
operator * (left: Int, right: TimeSpan) -> TimeSpan { right * left }
operator + (left: Long, right: TimeSpan) -> TimeSpan { right + left }
operator - (left: Long, right: TimeSpan) -> TimeSpan { right negate() + left }
operator * (left: Long, right: TimeSpan) -> TimeSpan { right * left }
operator + (left: Double, right: TimeSpan) -> TimeSpan { right + left }
operator - (left: Double, right: TimeSpan) -> TimeSpan { right negate() + left }
operator * (left: Double, right: TimeSpan) -> TimeSpan { right * left }
