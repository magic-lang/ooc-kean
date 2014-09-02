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

EventTest: class extends Fixture {
	init: func () {
		super("Event")
		this add("event", This event)
		this add("event1", This event1)
	}
	event: static func {
			counter0 := 0
			counter1 := 0
			e := Event new()
			e += Event new(func { counter0 += 1 })
			expect(counter0, is equal to(0))
			expect(counter1, is equal to(0))
			e call()
			expect(counter0, is equal to(1))
			expect(counter1, is equal to(0))
			e = e + (func { counter1 += 1 })
			e call()
			expect(counter0, is equal to(2))
			expect(counter1, is equal to(1))
	}
	event1: static func {
			counter0 := 0
			counter1 := 0
			counter2 := 0
			e := Event1<Int> new()
			e = e add(Event1<Int> new(func(delta: Int) {	counter0 += delta	}))
			expect(counter0, is equal to(0))
			expect(counter1, is equal to(0))
			expect(counter2, is equal to(0))
			e call(1)
			expect(counter0, is equal to(1))
			expect(counter1, is equal to(0))
			expect(counter2, is equal to(0))
			e = e add(Event1<Int> new(func(delta: Int) {	counter1 = counter1 + delta	}))
			e call(1)
			expect(counter0, is equal to(2))
			expect(counter1, is equal to(1))
			expect(counter2, is equal to(0))
			e call(1337)
			expect(counter0, is equal to(1339))
			expect(counter1, is equal to(1338))
			expect(counter2, is equal to(0))
			e = e add(func(delta: Int) {	counter2 = counter2 + delta	})
			e call(-1337)
			expect(counter0, is equal to(2))
			expect(counter1, is equal to(1))
			expect(counter2, is equal to(-1337))
	}
}
IntCell: class {
	value: Int
	init: func(=value)
}
EventTest new() run()
