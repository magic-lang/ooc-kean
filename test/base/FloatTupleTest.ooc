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

use unit
use base

FloatTupleTest: class extends Fixture {
	precision := 1.0e-5f
	init: func {
		super("FloatTuple")
		tuple2 := FloatTuple2 new(1.0f, 2.0f)
		tuple3 := FloatTuple3 new(1.0f, 2.0f, 3.0f)
		tuple4 := FloatTuple4 new(1.0f, 2.0f, 3.0f, 4.0f)
		this add("create", func {
			expect(tuple2 a, is equal to(1.0f) within(this precision))
			expect(tuple3 a, is equal to(1.0f) within(this precision))
			expect(tuple4 a, is equal to(1.0f) within(this precision))
			expect(tuple2 b, is equal to(2.0f) within(this precision))
			expect(tuple3 b, is equal to(2.0f) within(this precision))
			expect(tuple4 b, is equal to(2.0f) within(this precision))
			expect(tuple3 c, is equal to(3.0f) within(this precision))
			expect(tuple4 c, is equal to(3.0f) within(this precision))
			expect(tuple4 d, is equal to(4.0f) within(this precision))
		})
		this add("iterate", func {
			for (i in 0 .. 20) {
				expect(tuple2[i % 2], is equal to((i % 2 + 1) as Float) within(this precision))
				expect(tuple3[i % 3], is equal to((i % 3 + 1) as Float) within(this precision))
				expect(tuple4[i % 4], is equal to((i % 4 + 1) as Float) within(this precision))
			}
		})
	}
}

FloatTupleTest new() run() . free()
