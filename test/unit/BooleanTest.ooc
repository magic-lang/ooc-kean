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

use unit

// TODO: Skipping the variable and having "is not equal to" inside an expect call does not work
BooleanTest: class extends Fixture {
	init: func {
		super("Boolean")
		this add("true is true", func { expect(true, is true) })
		this add("false is false", func { expect(false, is false) })

		this add("true", func { expect(true) })

		this add("false is not true", func { expect(false, is not true) })
		this add("true is not false", func { expect(true, is not false) })

		notNotTrue := is not not true
		this add("true is not not true", func { expect(true, notNotTrue) })
		notNotFalse := is not not false
		this add("false is not not false", func { expect(false, notNotFalse) })

		this add("true is equal to true", func { expect(true, is equal to(true)) })
		this add("false is equal to false", func { expect(false, is equal to(false)) })
	}
}

BooleanTest new() run() . free()
