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

EquatableTest: class extends Fixture {
	init: func () {
		super("Equatable")
		four := EquatableImplementation new(4)
		this add("4 Equals 4 is true", func { expect(four equals(EquatableImplementation new(4)), is true) })
		this add("4 Equals 3 is not true", func { expect(four equals(EquatableImplementation new(3)), is not true) })
	}
}
EquatableImplementation: class implements IEquatable<EquatableImplementation> {
	value: Int
	init: func (=value) {	}
	equals: func (other: EquatableImplementation) -> Bool {
		this value == other value
	}
	toString: func -> String {
		this value toString()
	}
	create: static func (value: Int) -> IEquatable<Int> {
		This new(value)
	}
}
EquatableTest new() run()
