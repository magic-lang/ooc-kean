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
	init: func () {
		super("DateTime")
		this add("create from ticks", func() {
			d := DateTime new(10_000)
			expect(d ticks == 10_000)
		})
		this add("validate time", func(){
			expect( DateTime isHourValid(23, 10, 14) == true )
			expect( DateTime isHourValid(25, 0, 1) == false )
			expect( DateTime isHourValid(0, 60, 1) == false )
			expect( DateTime isHourValid(3, 23, -23) == false )
		})
	}
}
DateTimeTest new() run()
