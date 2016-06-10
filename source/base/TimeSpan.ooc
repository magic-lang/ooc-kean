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
	init: func@ ~fromHourMinuteSec (hour, minute, second, millisecond: Int) { this _ticks = DateTime timeToTicks(hour, minute, second, millisecond) }
	negate: func -> This { This new(-this ticks) }
	toNanoseconds: func -> Long { this ticks * DateTime nanosecondsPerTick }
	toMilliseconds: func -> Long { this ticks / DateTime ticksPerMillisecond }
	toSeconds: func -> Long { this ticks / DateTime ticksPerSecond }
	toMinutes: func -> Long { this ticks / DateTime ticksPerMinute }
	toHours: func -> Long { this ticks / DateTime ticksPerHour }
	toDays: func -> Long { this ticks / DateTime ticksPerDay }
	toWeeks: func -> Long { this ticks / DateTime ticksPerWeek }

	defaultFormat: static String = "%w weeks, %d days, %h hours, %m minutes, %s seconds, %z milliseconds"
	// Supported formatting expressions:
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
	toString: func (format := This defaultFormat) -> String {
		(weekString, dayString, hourString) := (this toWeeks(), this toDays(), this toHours()) toString()
		(minuteString, secondString, milliString) := (this toMinutes(), this toSeconds(), this toMilliseconds()) toString()
		(dayModString, hourModString, minuteModString) := (this toDays() modulo(7), this toHours() modulo(24), this toMinutes() modulo(60)) toString()
		(secondModString, milliModString) := (this toSeconds() modulo(60), this toMilliseconds() modulo(1000)) toString()
		second := format replaceAll("%w", weekString)
		result := second replaceAll("%D", dayString)
		second free()
		second = result replaceAll("%H", hourString)
		result free()
		result = second replaceAll("%M", minuteString)
		second free()
		second = result replaceAll("%S", secondString)
		result free()
		result = second replaceAll("%Z", milliString)
		second free()
		second = result replaceAll("%d", dayModString)
		result free()
		result = second replaceAll("%h", hourModString)
		second free()
		second = result replaceAll("%m", minuteModString)
		result free()
		result = second replaceAll("%s", secondModString)
		second free()
		second = result replaceAll("%z", milliModString)
		(result, weekString, dayString, hourString, minuteString, secondString, milliString, dayModString, hourModString, minuteModString, secondModString, milliModString) free()
		second
	}
	compareTo: func (other: This) -> Order {
		if (this ticks > other ticks)
			Order Greater
		else if (this ticks < other ticks)
			Order Less
		else
			Order Equal
	}

	operator + (other: This) -> This { This new(this ticks + other ticks) }
	operator - (other: This) -> This { This new(this ticks - other ticks) }
	operator == (other: This) -> Bool { this compareTo(other) == Order Equal }
	operator != (other: This) -> Bool { !(this == other) }
	operator > (other: This) -> Bool { this compareTo(other) == Order Greater }
	operator < (other: This) -> Bool { this compareTo(other) == Order Less }
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

	maximumValue ::= static This new(Long maximumValue)
	minimumValue ::= static This new(Long minimumValue)

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
