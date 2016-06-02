/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base

DateTimeTest: class extends Fixture {
	init: func {
		super("DateTime")
		this add("create from ticks", func {
			d := DateTime new(10_000)
			expect(d ticks == 10_000)
			d = DateTime new(0)
			expect(d ticks == 0)
		})
		this add("time to ticks", func {
			t := DateTime timeToTicks(0, 0, 1, 0)
			expect(t == DateTime ticksPerSecond)
			t = DateTime timeToTicks(0, 1, 0, 0)
			expect(t == DateTime ticksPerMinute)
			t = DateTime timeToTicks(1, 0, 0, 0)
			expect(t == DateTime ticksPerHour)
			t = DateTime timeToTicks(1, 2, 3, 0)
			expect(t == 1 * DateTime ticksPerHour + 2 * DateTime ticksPerMinute + 3 * DateTime ticksPerSecond)
		})
		this add("validate time", func {
			expect(DateTime timeIsValid(23, 10, 14, 0), is true)
			expect(DateTime timeIsValid(25, 0, 1, 0), is false)
			expect(DateTime timeIsValid(0, 60, 1, 999), is false)
			expect(DateTime timeIsValid(3, 23, -23, 1), is false)
			expect(DateTime timeIsValid(3, 23, 15, 1001), is false)
		})
		this add("validate date", func {
			expect(DateTime dateIsValid(1983, 1, 3), is true)
			expect(DateTime dateIsValid(1983, 1, 0), is false)
			expect(DateTime dateIsValid(0, 30, 3), is false)
			expect(DateTime dateIsValid(1983, 0, 3), is false)
			// leap year dates
			expect(DateTime dateIsValid(2000, 2, 29), is true)
			expect(DateTime dateIsValid(1998, 2, 29), is false)
		})
		this add("create from h/m/s", func {
			d := DateTime new ~fromHourMinuteSec(10, 12, 56, 895)
			expect(d millisecond() == 895)
			expect(d second() == 56)
			expect(d minute() == 12)
			expect(d hour() == 10)
		})
		this add("create from y/m/d", func {
			d := DateTime new ~fromYearMonthDay(1, 1, 1)
			expect(d ticks == 0)
			expect(d year() == 1)
			d = DateTime new ~fromYearMonthDay(1, 1, 13)
			expect(d ticks == (DateTime ticksPerDay * 12))
			d = DateTime new ~fromYearMonthDay(1950, 7, 23)
			expect(d year() == 1950)
			expect(d month() == 7)
			expect(d day() == 23)
			expect(d hour() == 0)
			expect(d minute() == 0)
			expect(d second() == 0)
			expect(d millisecond() == 0)
		})
		this add("create from y/m/d/hh/mm/ss/ms", func {
			d := DateTime new ~fromDateTime(2015, 7, 28, 10, 29, 15, 764)
			expect(d year() == 2015)
			expect(d month() == 7)
			expect(d day() == 28)
			expect(d hour() == 10)
			expect(d minute() == 29)
			expect(d second() == 15)
			expect(d millisecond() == 764)
			d = DateTime new(1921, 11, 30, 12, 22, 7, 94)
			expect(d year() == 1921)
			expect(d month() == 11)
			expect(d day() == 30)
			expect(d hour() == 12)
			expect(d minute() == 22)
			expect(d second() == 7)
			expect(d millisecond() == 94)
			d = DateTime new(235, 1, 2, 0, 0, 0, 1)
			expect(d year() == 235)
			expect(d month() == 1)
			expect(d day() == 2)
			expect(d hour() == 0)
			expect(d minute() == 0)
			expect(d second() == 0)
			expect(d millisecond() == 1)
			// test some leap years
			d = DateTime new ~fromYearMonthDay(4, 1, 1)
			expect(d year() == 4)
			expect(d month() == 1)
			expect(d day() == 1)
			d = DateTime new ~fromYearMonthDay(1600, 12, 12)
			expect(d year() == 1600)
			expect(d month() == 12)
			expect(d day() == 12)
			d = DateTime new ~fromYearMonthDay(2000, 1, 9)
			expect(d year() == 2000)
			expect(d month() == 1)
			expect(d day() == 9)
			d = DateTime new ~fromYearMonthDay(1552, 12, 1)
			expect(d year() == 1552)
			expect(d month() == 12)
			expect(d day() == 1)
		})
		this add("ordering operators", func {
			d1 := DateTime new ~fromYearMonthDay(2000, 1, 2)
			d2 := DateTime new ~fromYearMonthDay(2000, 1, 3)
			expect(d1 < d2)
			expect(d1 <= d2)
			expect(d1 != d2)
			expect(d2 > d1)
			expect(d2 >= d1)
			expect(d1 == d1)
		})
		this add("TimeSpan operators", func {
			d1 := DateTime new ~fromYearMonthDay(2000, 1, 3)
			d2 := DateTime new ~fromYearMonthDay(2000, 1, 2)
			span := d1 - d2
			expect(span toDays() == 1)
			expect(span toHours() == 24)
			expect(span toMinutes() == 24 * 60)
			expect(d2 + span == d1)
			expect(d1 - span == d2)
			span = span negate()
			expect(d1 + span == d2)
			expect(d2 - span == d1)
			d1 = DateTime new(1555, 12, 26, 14, 15, 53, 84)
			d2 = d1 + TimeSpan hour()
			expect(d2 year() == 1555)
			expect(d2 month() == 12)
			expect(d2 day() == 26)
			expect(d2 hour() == 15)
			expect(d2 minute() == 15)
			expect(d2 second() == 53)
			expect(d2 millisecond() == 84)
			d2 = d2 + TimeSpan week() * 2
			expect(d2 year() == 1556)
			expect(d2 month() == 1)
			expect(d2 day() == 9)
			expect(d2 hour() == 15)
			expect(d2 minute() == 15)
			expect(d2 second() == 53)
			expect(d2 millisecond() == 84)
			d1 = d2 + TimeSpan day()
			span = d1 - d2
			expect(span == TimeSpan day())
			d2 = d1
			d1 += span
			expect(d1 - d2 == TimeSpan day())
			d1 -= TimeSpan week()
			expect((d2 - d1) toDays() == 6)
		})
		this add("toString", func {
			date := DateTime new(1643, 12, 31, 23, 58, 59, 999)
			Astring := date toString("%yyyy-%MM-%dd %hh:%mm:%ss.%zzz")
			Bstring := date toString("%yy-%M-%d %h:%m:%s.%z")
			expect(Astring, is equal to("1643-12-31 23:58:59.999"))
			expect(Bstring, is equal to("43-12-31 23:58:59.999"))

			date = DateTime new(1998, 7, 18, 1, 44, 31, 742)
			Cstring := date toString("date is : %yy, %M, %dd; hour: %hh-%mm-%ss")
			Dstring := date toString("%yyyy/%dd/%MM")
			Estring := date toString()
			Estringcompare := date toString(DateTime defaultFormat)
			expect(Cstring, is equal to("date is : 98, 7, 18; hour: 01-44-31"))
			expect(Dstring, is equal to("1998/18/07"))
			expect(Estring == Estringcompare)

			date = DateTime new ~fromYearMonthDay(1, 1, 1)
			Fstring := date toString("start date is: %yy %M %d, %hh-%mm-%ss-%zzz")
			Gstring := date toString("%h-%m-%s-%z")
			expect(Fstring, is equal to("start date is: 01 1 1, 00-00-00-000"))
			expect(Gstring, is equal to("0-0-0-0"))

			(Astring, Bstring, Cstring, Dstring, Estring, Fstring, Gstring, Estringcompare) free()
		})
		this add("current time", func {
			d := DateTime now
			expect(d > DateTime new(0))
		})
	}
}

DateTimeTest new() run() . free()
