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

IntegerTest: class extends Fixture {
	init: func {
		super("Integer")
		this add("0 is equal to 0", func { expect(0, is equal to(0)) })
		this add("1 is equal to 1", func { expect(1, is equal to(1)) })
		this add("2 is equal to 2", func { expect(2, is equal to(2)) })
		this add("9 is equal to 9", func { expect(9, is equal to(9)) })
		this add("10 is equal to 10", func { expect(10, is equal to(10)) })
		this add("100 is equal to 100", func { expect(100, is equal to(100)) })
		this add("-1 is equal to -1", func { expect(-1, is equal to(-1)) })
		this add("42 is equal to 42", func { expect(42, is equal to(42)) })
		this add("-1337 is equal to -1337", func { expect(-1337, is equal to(-1337)) })
		isNotEqualTo42 := is not equal to(42)
		this add("0 is not equal to 42", func { expect(0, isNotEqualTo42) })
		this add("0 is equal to -0", func { expect(0, is equal to(-0)) })
		this add("0 is less than 1", func { expect(0, is less than(1)) })
		this add("0.0 is greater than -1", func { expect(0, is greater than(-1)) })
	}
}

IntegerTest new() run() . free()
