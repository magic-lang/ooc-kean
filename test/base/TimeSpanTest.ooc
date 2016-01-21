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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

use unit
use base

TimeSpanTest: class extends Fixture {
	init: func {
		super("TimeSpan")
		this add("test compareTo", func {
			t1 := TimeSpan new(1000)
			t2 := TimeSpan new(2000)
			expect(t1 compareTo(t2) == Order less)
			expect(t1 compareTo(t1) == Order equal)
			expect(t2 compareTo(t1) == Order greater)
			expect(t2 compareTo(t2) == Order equal)
			expect(t2 == t2)
			expect(t1 < t2)
			expect(t2 > t1)
			expect(t2 != t1)
			expect(t2 >= t1)
			expect(t1 <= t2)
			expect(TimeSpan millisecond() * 100 < TimeSpan second())
			expect(TimeSpan week() > TimeSpan day())
			expect(TimeSpan day() != TimeSpan day() * 1.5)
		})
		this add("test addition", func {
			t := TimeSpan new(100)
			t2 := t + 50
			expect((t + TimeSpan new(-100)) ticks == 0)
			expect((t + TimeSpan new(-230)) ticks == -130)
			expect((t + TimeSpan new(100)) ticks == 200)
			expect(t2 ticks == 150 )
			expect(TimeSpan day() * 6 + TimeSpan day() == TimeSpan week())
			expect(TimeSpan second() + TimeSpan second() == TimeSpan second() * 2)
			t = TimeSpan second()
			t = t + 1.25
			expect(t elapsedSeconds() == 2)
			expect(t elapsedMilliseconds() == 2250)
			expect(t + 1.9 == 1.9 + t)
			expect(1.0 + TimeSpan new(0) == TimeSpan second())
			expect((0.9 + TimeSpan second() + 3.1) elapsedMilliseconds() == 5000)
			t += 800 * DateTime ticksPerMillisecond
			expect(t elapsedMilliseconds() == 3050)
			t += 0.5
			expect(t elapsedMilliseconds() == 3550)
			t -= 2.5
			expect(t elapsedMilliseconds() == 1050)
			t -= 1050 * DateTime ticksPerMillisecond
			expect(t ticks == 0)
			t = TimeSpan second()
			t *= 4
			expect(t elapsedSeconds() == 4)
			t *= 2.5
			expect(t elapsedSeconds() == 10)
		})
		this add("test subtraction", func {
			t := TimeSpan new(100)
			expect((t - TimeSpan new(50)) ticks == 50)
			expect((t - t) ticks == 0)
			expect(TimeSpan week() - TimeSpan days(6) == TimeSpan day())
			expect(TimeSpan hour() - TimeSpan minute() == TimeSpan minutes(59))
			expect(TimeSpan minute() - TimeSpan millisecond() == TimeSpan second() * 59 + TimeSpan millisecond() * 999)
			expect((TimeSpan hour() - TimeSpan minute()) elapsedHours() == 0)
			expect((TimeSpan hour() - TimeSpan minute()) elapsedMinutes() == 59)
			expect(t - 10 == 190 - t)
			t = TimeSpan second()
			expect((1.0 - t) ticks == 0)
		})
		this add("test negation", func {
			t := TimeSpan new(200)
			t = t negate()
			expect(t ticks == -200 )
			expect((t + (t negate())) ticks == 0)
		})
		this add("test multiplication", func {
			expect((TimeSpan millisecond() * 1.5) ticks == DateTime ticksPerMillisecond * 1.5)
			expect(TimeSpan second() * 2 == TimeSpan second() + TimeSpan second())
			expect(TimeSpan day() * 7 == TimeSpan week())
			expect(TimeSpan millisecond() * 1000.0 == TimeSpan second())
			t := TimeSpan new ~fromHourMinuteSec(0, 0, 1, 0)
			expect(2.0 * t == TimeSpan seconds(2))
			expect((2000 * DateTime ticksPerMillisecond + TimeSpan second()) elapsedSeconds() == 3)
		})
		this add("test division", func {
			expect((TimeSpan days(2) / 2) elapsedDays() == 1)
			expect((TimeSpan weeks(1) / 0.5) elapsedDays() == 14)
			t := TimeSpan day() + TimeSpan hours(8)
			t /= 32
			expect(t elapsedHours() == 1)
			t = TimeSpan days(100)
			t /= 25.0
			expect(t elapsedDays() == 4)
		})
		this add("test creation helpers", func {
			expect(TimeSpan millisecond() elapsedMilliseconds() == 1)
			expect(TimeSpan millisecond() elapsedSeconds() == 0)
			expect(TimeSpan second() elapsedSeconds() == 1)
			expect(TimeSpan second() elapsedMinutes() == 0)
			expect(TimeSpan minute() elapsedMinutes() == 1)
			expect(TimeSpan hour() elapsedMinutes() == 60)
			expect(TimeSpan hour() elapsedHours() == 1)
			expect(TimeSpan day() elapsedHours() == 24)
			expect(TimeSpan week() elapsedDays() == 7)
			expect(TimeSpan milliseconds(10) elapsedMilliseconds() == 10)
			expect(TimeSpan seconds(8.5) elapsedMilliseconds() == 8500)
			expect(TimeSpan minutes(60) elapsedHours() == 1)
			expect(TimeSpan hours(55) elapsedHours() == 55)
			expect(TimeSpan hours(2.5) elapsedMinutes() == 150)
			expect(TimeSpan days(14.1) elapsedWeeks() == 2)
			expect(TimeSpan weeks(2) elapsedDays() == 14)
		})
		this add("toText", func {
			span := TimeSpan millisecond() + TimeSpan second() + TimeSpan minute() + TimeSpan hour() + TimeSpan day() + TimeSpan week()
			expect(span toText() == t"1 weeks, 1 days, 1 hours, 1 minutes, 1 seconds, 1 milliseconds")
			expect(span toText(t"%D") == t"8")
			expect(TimeSpan day() toText(t"%H %M %S %h %m %s") == t"24 1440 86400 0 0 0")
			expect(TimeSpan hour() toText(t"%d %D text %m %M") == t"0 0 text 0 60")
		})
	}
}

TimeSpanTest new() run() . free()
