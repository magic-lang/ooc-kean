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

EqualsWithinTest: class extends Fixture {
	init: func () {
		super("EqualsWithin")
		this add("4 Equals 4 Within 0 is true", func() { expect(EqualsWithinImplementation new(4) Equals(4, 0), is true) })
		this add("4 Equals 3 Within 0 is not true", func() { expect(EqualsWithinImplementation new(4) Equals(3, 0), is not true) })
		this add("4 Equals 3 Within 0 is true", func() { expect(EqualsWithinImplementation new(4) Equals(3, 2), is true) })
		this add("4 Equals 2 Within 0 is true", func() { expect(EqualsWithinImplementation new(4) Equals(2, 2), is true) })
		this add("4 Equals 1 Within 0 is not true", func() { expect(EqualsWithinImplementation new(4) Equals(1, 2), is not true) })
	}
}
EqualsWithinImplementation: class implements IEqualsWithin<Int, Int> {
	value: Int
	init: func (=value) {	}
	Equals: func (other: Int, precision: Int) -> Bool {
		(this value - other) abs() <= precision
	}
}
EqualsWithinTest new() run()
