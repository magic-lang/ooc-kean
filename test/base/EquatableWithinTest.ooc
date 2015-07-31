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

EquatableWithinTest: class extends Fixture {
	init: func () {
		super("EquatableWithin")
		four := EquatableWithinImplementation new(4)
		this add("4 Equals 4 Within 0 is true", func { expect(four equals(Cell new(4), Cell new(0)), is true) })
		this add("4 Equals 3 Within 0 is not true", func { expect(four equals(Cell new(3), Cell new(0)), is not true) })
		this add("4 Equals 3 Within 0 is true", func { expect(four equals(Cell new(3), Cell new(2)), is true) })
		this add("4 Equals 2 Within 0 is true", func { expect(four equals(Cell new(2), Cell new(2)), is true) })
		this add("4 Equals 1 Within 0 is not true", func { expect(four equals(Cell new(1), Cell new(2)), is not true) })
	}
}
EquatableWithinImplementation: class implements IEquatableWithin<Cell<Int>, Cell<Int>> {
	value: Int
	init: func (=value) {	}
	equals: func (other: Cell<Int>, precision: Cell<Int>) -> Bool {
		(this value - other get()) abs() <= precision get()
	}
	create: static func (.value) -> IEquatableWithin<Cell<Int>, Cell<Int>> {
		EquatableWithinImplementation new(value)
	}
}
EquatableWithinTest new() run()
