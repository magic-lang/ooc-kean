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

EqualsTest: class extends Fixture {
	init: func () {
		super("Equals")
		this add("4 Equals 4 is true", func() { expect(EqualsImplementation new(4) Equals(4), is true) })
		this add("4 Equals 3 is not true", func() { expect(EqualsImplementation new(4) Equals(3), is not true) })
	}
}
EqualsImplementation: class implements IEquals<Int> {
	value: Int
	init: func (=value) {	}
	Equals: func (other: Int) -> Bool {
		this value == other
	}
}
EqualsTest new() run()
