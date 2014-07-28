/*
 * Copyright(C) 2014 - Simon Mika<simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or(at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see<http://www.gnu.org/licenses/>.
 */

use ooc-unit

EqualsTest: class extends Fixture {
	init: func {
		super("Equals")
		this add("0 is equal to 0", func { expect(EqualsImplementer new (0), is equal to(0)) })
		this add("1 is equal to 1", func { expect(EqualsImplementer new (1), is equal to(1)) })
		this add("2 is equal to 2", func { expect(EqualsImplementer new (2), is equal to(2)) })
		this add("9 is equal to 9", func { expect(EqualsImplementer new (9), is equal to(9)) })
		this add("10 is equal to 10", func { expect(EqualsImplementer new (10), is equal to(10)) })
		this add("100 is equal to 100", func { expect(EqualsImplementer new (100), is equal to(100)) })
		this add("-1 is equal to -1", func { expect(EqualsImplementer new (-1), is equal to(-1)) })
		this add("42 is equal to 42", func { expect(EqualsImplementer new (42), is equal to(42)) })
		this add("-1337 is equal to -1337", func { expect(EqualsImplementer new (-1337), is equal to(-1337)) })
		isNotEqualTo42 := is not equal to(42)
		this add("0 is not equal to 42", func { expect(EqualsImplementer new (0), isNotEqualTo42) })
		this add("0 is equal to -0", func { expect(EqualsImplementer new (0), is equal to(-0)) })
	}
}
EqualsImplementer: class implements IEquals<Int> {
	value: Int
	init: func (=value)
	equals: func (other: Int) {
		this value == other
	}
}
EqualsTest new() run()
