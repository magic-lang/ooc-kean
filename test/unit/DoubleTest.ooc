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

DoubleTest: class extends Fixture {
	init: func {
		super("Double")
		this add("0.0 is equal to 0.0", func { expect(0.0, is equal to(0.0)) })
		this add("1.0 is equal to 1.0", func { expect(1.0, is equal to(1.0)) })
		this add("2.0 is equal to 2", func { expect(2.0, is equal to(2.0)) })
		this add("9.0 is equal to 9", func { expect(9.0, is equal to(9.0)) })
		this add("10.0 is equal to 10", func { expect(10.0, is equal to(10.0)) })
		this add("100.0 is equal to 100", func { expect(100.0, is equal to(100.0)) })
		this add("-1.0 is equal to -1", func { expect(-1.0, is equal to(-1.0)) })
		this add("4.2 is equal to 4.2", func { expect(4.2, is equal to(4.2)) })
		this add("-13.37 is equal to -13.37", func { expect(-13.37, is equal to(-13.37)) })
		this add("-13.37 is equal to -13.38 within 0.1", func { expect(-13.37, is equal to(-13.38) within(0.1)) })
		isNotEqualTo1338 := is not equal to(-13.38)
		this add("-13.37 is not equal to -13.38 within 0.001", func { expect(-13.37, isNotEqualTo1338 within(0.001)) })
		isNotEqualTo42 := is not equal to(4.2)
		this add("0.0 is not equal to 4.2", func { expect(0.0, isNotEqualTo42) })
		this add("0.0 is equal to -0.0", func { expect(0.0, is equal to(-0.0)) })
		this add("0.0 is less than 0.00000001", func { expect(0.0, is less than(0.00000001)) })
		this add("0.0 is greater than -0.00000001", func { expect(0.0, is greater than(-0.00000001)) })
	}
}

DoubleTest new() run() . free()
