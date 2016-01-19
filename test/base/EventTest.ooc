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
use base

IntCell: class {
	value: Int
	init: func (=value)
}

EventTest: class extends Fixture {
	init: func {
		super("Event")
		this add("event", This event)
		this add("event1", This event1)
		this add("event2", This event2)
	}
	event: static func {
		counter0 := 0
		counter1 := 0
		e := Event new()
		e add(Event new(func { counter0 += 1 }))
		expect(counter0, is equal to(0))
		expect(counter1, is equal to(0))
		e call()
		expect(counter0, is equal to(1))
		expect(counter1, is equal to(0))
		e add(func { counter1 += 1 })
		e call()
		expect(counter0, is equal to(2))
		expect(counter1, is equal to(1))
		e free()
	}
	event1: static func {
		counter0 := 0
		counter1 := 0
		counter2 := 0
		e := Event1<Int> new()
		e add(Event1<Int> new(func (delta: Int) { counter0 += delta }))
		expect(counter0, is equal to(0))
		expect(counter1, is equal to(0))
		expect(counter2, is equal to(0))
		e call(1)
		expect(counter0, is equal to(1))
		expect(counter1, is equal to(0))
		expect(counter2, is equal to(0))
		e add(Event1<Int> new(func (delta: Int) { counter1 += delta }))
		e call(1)
		expect(counter0, is equal to(2))
		expect(counter1, is equal to(1))
		expect(counter2, is equal to(0))
		e call(1337)
		expect(counter0, is equal to(1339))
		expect(counter1, is equal to(1338))
		expect(counter2, is equal to(0))
		e add(func (delta: Int) { counter2 += delta })
		e call(-1337)
		expect(counter0, is equal to(2))
		expect(counter1, is equal to(1))
		version(debugTests)
			counter2 toString() println()

		expect(counter2, is equal to(-1337))
		e free()
	}
	event2: static func {
		counter0 := 0
		counter1 := 0
		counter2 := 0
		string0 := ""
		string1 := ""
		string2 := ""
		e := Event2<Int, String> new()
		e add(Event2<Int, String> new(func (delta: Int, s: String) { counter0 += delta; string0 >>= s }))
		expect(counter0, is equal to(0))
		expect(counter1, is equal to(0))
		expect(counter2, is equal to(0))
		expect(string0, is equal to(""))
		expect(string1, is equal to(""))
		expect(string2, is equal to(""))
		e call(1, "a")
		expect(counter0, is equal to(1))
		expect(counter1, is equal to(0))
		expect(counter2, is equal to(0))
		expect(string0, is equal to("a"))
		expect(string1, is equal to(""))
		expect(string2, is equal to(""))
		e add(Event2<Int, String> new(func (delta: Int, s: String) { counter1 += delta; string1 >>= s }))
		e call(1, "b")
		expect(counter0, is equal to(2))
		expect(counter1, is equal to(1))
		expect(counter2, is equal to(0))
		expect(string0, is equal to("ab"))
		expect(string1, is equal to("b"))
		expect(string2, is equal to(""))
		e call(1337, "c")
		expect(counter0, is equal to(1339))
		expect(counter1, is equal to(1338))
		expect(counter2, is equal to(0))
		expect(string0, is equal to("abc"))
		expect(string1, is equal to("bc"))
		expect(string2, is equal to(""))
		e add(func (delta: Int, s: String) { counter2 += delta; string2 >>= s })
		e call(-1337, "d")
		expect(counter0, is equal to(2))
		expect(counter1, is equal to(1))
		expect(counter2, is equal to(-1337))
		expect(string0, is equal to("abcd"))
		expect(string1, is equal to("bcd"))
		expect(string2, is equal to("d"))
		string0 free(); string1 free(); string2 free()
		e free()
	}
}

EventTest new() run() . free()
