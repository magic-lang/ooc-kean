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

use ooc-unit
use ooc-base

TimeSpanTest: class extends Fixture {
	init: func () {
		super("TimeSpan")
		this add("test compareTo", func() {
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
		})
		this add("test add", func() {
			t := TimeSpan new(100)
			t2 := t + 50
			expect((t + TimeSpan new(-100)) ticks == 0)
			expect((t + TimeSpan new(-230)) ticks == -130)
			expect((t + TimeSpan new(100)) ticks == 200)
			expect(t2 ticks == 150 )
		})
		this add("test subtract", func() {
			t := TimeSpan new(100)
			expect((t - TimeSpan new(50)) ticks == 50)
			expect((t - t) ticks == 0)
		})
		this add("test negate", func() {
			t := TimeSpan new(200)
			t = t negate()
			expect(t ticks == -200 )
			expect((t + (t negate())) ticks == 0)
		})
		this add("test creation helpers", func() {
			expect(TimeSpan millisecond() elapsedMilliseconds() == 1)
			expect(TimeSpan millisecond() elapsedSeconds() == 0)
			expect(TimeSpan second() elapsedSeconds() == 1)
			expect(TimeSpan second() elapsedMinutes() == 0)
			expect(TimeSpan minute() elapsedMinutes() == 1)
			expect(TimeSpan hour() elapsedMinutes() == 60)
			expect(TimeSpan hour() elapsedHours() == 1)
			expect(TimeSpan day() elapsedHours() == 24)
			expect(TimeSpan week() elapsedDays() == 7)
		})
	}
}
TimeSpanTest new() run()
