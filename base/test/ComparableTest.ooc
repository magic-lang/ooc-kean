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

ComparableTest: class extends Fixture {
	init: func () {
		super("Comparable")
		four := ComparableImplementation new(4)
		this add("4 Compare 4 is Equal", func() { expect(four compare(ComparableImplementation new(4)) == Order equal, is true) })
		this add("4 Compare 3 is Greater", func() { expect(four compare(ComparableImplementation new(3)) == Order greater, is true) })
		this add("4 Compare 5 is Less", func() { expect(four compare(ComparableImplementation new(5)) == Order less, is true) })
	}
}
ComparableImplementation: class implements IComparable<ComparableImplementation> {
	value: Int
	init: func (=value) {	}
	compare: func (other: ComparableImplementation) -> Order {
		(this toString() + " == " + other toString()) println()
		if (this value == other value)
			Order equal
		else if (this value > other value)
			Order greater
		else
			Order less
	}
	toString: func -> String {
		this value toString()
	}
	create: static func (.value) -> IComparable<ComparableImplementation> {
		ComparableImplementation new(value)
	}
}
ComparableTest new() run()
