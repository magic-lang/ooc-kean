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

DateTimeTest: class extends Fixture {
	init: func {
		super("DateTime")
		this add("datetime", This datetime)
	}
	datetime: static func {
    date1 := DateTime new(2014, 9, 3)
    date2 := DateTime new(2014, 9, 3)
		expect(date1 == date2, is true)
    date1 += TimeSpan new(0, 0, 0, 1)
    expect(date1 == DateTime new(2014, 9, 3, 0, 0, 1))
    expect(date1 > date2, is true)
    expect(date1 < date2, is false)
    expect(date1 == date2, is false)
    expect(date2 > date1, is false)
    expect(date2 < date1, is true)
    expect(date2 == date1, is false)
    date2 -= TimeSpan new(0, 0, 0, 1)
    expect(date2 == DateTime new(2014, 9, 2, 23, 59, 59))
	}
}
DateTimeTest new() run()
