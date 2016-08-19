/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base

TimeSpanTest: class extends Fixture {
	init: func {
		super("TimeSpan")
		this add("test compareTo", func {
			t1 := TimeSpan new(1000)
			t2 := TimeSpan new(2000)
			expect(t1 compareTo(t2) == Order Less)
			expect(t1 compareTo(t1) == Order Equal)
			expect(t2 compareTo(t1) == Order Greater)
			expect(t2 compareTo(t2) == Order Equal)
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
			expect(t2 ticks == 150)
			expect(TimeSpan day() * 6 + TimeSpan day() == TimeSpan week())
			expect(TimeSpan second() + TimeSpan second() == TimeSpan second() * 2)
			t = TimeSpan second()
			t = t + 1.25
			expect(t toSeconds() == 2)
			expect(t toMilliseconds() == 2250)
			expect(t + 1.9 == 1.9 + t)
			expect(1.0 + TimeSpan new(0) == TimeSpan second())
			expect((0.9 + TimeSpan second() + 3.1) toMilliseconds() == 5000)
			t += 800 * DateTime ticksPerMillisecond
			expect(t toMilliseconds() == 3050)
			t += 0.5
			expect(t toMilliseconds() == 3550)
			t -= 2.5
			expect(t toMilliseconds() == 1050)
			t -= 1050 * DateTime ticksPerMillisecond
			expect(t ticks == 0)
			t = TimeSpan second()
			t *= 4
			expect(t toSeconds() == 4)
			t *= 2.5
			expect(t toSeconds() == 10)
		})
		this add("test subtraction", func {
			t := TimeSpan new(100)
			expect((t - TimeSpan new(50)) ticks == 50)
			expect((t - t) ticks == 0)
			expect(TimeSpan week() - TimeSpan days(6) == TimeSpan day())
			expect(TimeSpan hour() - TimeSpan minute() == TimeSpan minutes(59))
			expect(TimeSpan minute() - TimeSpan millisecond() == TimeSpan second() * 59 + TimeSpan millisecond() * 999)
			expect((TimeSpan hour() - TimeSpan minute()) toHours() == 0)
			expect((TimeSpan hour() - TimeSpan minute()) toMinutes() == 59)
			expect(t - 10 == 190 - t)
			t = TimeSpan second()
			expect((1.0 - t) ticks == 0)
		})
		this add("test negation", func {
			t := TimeSpan new(200)
			t = t negate()
			expect(t ticks == -200)
			expect((t + (t negate())) ticks == 0)
		})
		this add("test multiplication", func {
			expect((TimeSpan millisecond() * 1.5) ticks == DateTime ticksPerMillisecond * 1.5)
			expect(TimeSpan second() * 2 == TimeSpan second() + TimeSpan second())
			expect(TimeSpan day() * 7 == TimeSpan week())
			expect(TimeSpan millisecond() * 1000.0 == TimeSpan second())
			t := TimeSpan new ~fromHourMinuteSec(0, 0, 1, 0)
			expect(2.0 * t == TimeSpan seconds(2))
			expect((2000 * DateTime ticksPerMillisecond + TimeSpan second()) toSeconds() == 3)
		})
		this add("test division", func {
			expect((TimeSpan days(2) / 2) toDays() == 1)
			expect((TimeSpan weeks(1) / 0.5) toDays() == 14)
			t := TimeSpan day() + TimeSpan hours(8)
			t /= 32
			expect(t toHours() == 1)
			t = TimeSpan days(100)
			t /= 25.0
			expect(t toDays() == 4)
		})
		this add("test creation helpers", func {
			expect(TimeSpan millisecond() toMilliseconds() == 1)
			expect(TimeSpan millisecond() toSeconds() == 0)
			expect(TimeSpan second() toSeconds() == 1)
			expect(TimeSpan second() toMinutes() == 0)
			expect(TimeSpan minute() toMinutes() == 1)
			expect(TimeSpan hour() toMinutes() == 60)
			expect(TimeSpan hour() toHours() == 1)
			expect(TimeSpan day() toHours() == 24)
			expect(TimeSpan week() toDays() == 7)
			expect(TimeSpan milliseconds(10) toMilliseconds() == 10)
			expect(TimeSpan seconds(8.5) toMilliseconds() == 8500)
			expect(TimeSpan minutes(60) toHours() == 1)
			expect(TimeSpan hours(55) toHours() == 55)
			expect(TimeSpan hours(2.5) toMinutes() == 150)
			expect(TimeSpan days(14.1) toWeeks() == 2)
			expect(TimeSpan weeks(2) toDays() == 14)
			expect(TimeSpan milliseconds(13) toNanoseconds() == 13_000_000)
		})
		this add("toString", func {
			span := TimeSpan millisecond() + TimeSpan second() + TimeSpan minute() + TimeSpan hour() + TimeSpan day() + TimeSpan week()
			defaultString := span toString()
			expect(defaultString, is equal to("1 weeks, 1 days, 1 hours, 1 minutes, 1 seconds, 1 milliseconds"))
			dayString := span toString("%D")
			expect(dayString, is equal to("8"))
			Astring := TimeSpan day() toString("%H %M %S %h %m %s")
			expect(Astring, is equal to("24 1440 86400 0 0 0"))
			Bstring := TimeSpan hour() toString("%d %D text %m %M")
			expect(Bstring, is equal to("0 0 text 0 60"))
			negativeSpan := TimeSpan day() negate()
			negativeString := negativeSpan toString("%H %M %S %h %m %s")
			expect(negativeString, is equal to("-(24 1440 86400 0 0 0)"))
			(defaultString, dayString, Astring, Bstring, negativeString) free()
		})
		this add("inRange", func {
			span := TimeSpan milliseconds(30)
			expect(span inRange(TimeSpan milliseconds(1), TimeSpan milliseconds(25)), is false)
			expect(span inRange(TimeSpan milliseconds(31), TimeSpan milliseconds(50)), is false)
			expect(span inRange(TimeSpan milliseconds(29), TimeSpan milliseconds(30)), is true)
			expect(span inRange(TimeSpan milliseconds(30), TimeSpan milliseconds(31)), is true)
		})
	}
}

TimeSpanTest new() run() . free()
