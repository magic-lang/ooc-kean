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
		this add("4 Compare 4 is Equal", func() { expect(ComparableImplementation new(4) Compare(4) == Order Equal, is true) })
		this add("4 Compare 3 is Greater", func() { expect(ComparableImplementation new(4) Compare(3) == Order Greater, is true) })
		this add("3 Compare 4 is Less", func() { expect(ComparableImplementation new(3) Compare(4) == Order Less, is true) })
	}
}
ComparableImplementation: class implements IComparable<Int> {
	value: Int
	init: func (=value) {	}
	Compare: func (other: Int) -> Order {
		if (value == other)
			Order Equal
		else if (value > other)
			Order Greater
		else
			Order Less
	}
}
ComparableTest new() run()
