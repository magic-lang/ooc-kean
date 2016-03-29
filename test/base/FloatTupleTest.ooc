/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base

FloatTupleTest: class extends Fixture {
	init: func {
		tolerance := 1.0e-5f
		super("FloatTuple")
		tuple2 := FloatTuple2 new(1.0f, 2.0f)
		tuple3 := FloatTuple3 new(1.0f, 2.0f, 3.0f)
		tuple4 := FloatTuple4 new(1.0f, 2.0f, 3.0f, 4.0f)
		this add("create", func {
			expect(tuple2 a, is equal to(1.0f) within(tolerance))
			expect(tuple3 a, is equal to(1.0f) within(tolerance))
			expect(tuple4 a, is equal to(1.0f) within(tolerance))
			expect(tuple2 b, is equal to(2.0f) within(tolerance))
			expect(tuple3 b, is equal to(2.0f) within(tolerance))
			expect(tuple4 b, is equal to(2.0f) within(tolerance))
			expect(tuple3 c, is equal to(3.0f) within(tolerance))
			expect(tuple4 c, is equal to(3.0f) within(tolerance))
			expect(tuple4 d, is equal to(4.0f) within(tolerance))
		})
		this add("iterate", func {
			for (i in 0 .. 20) {
				expect(tuple2[i % 2], is equal to((i % 2 + 1) as Float) within(tolerance))
				expect(tuple3[i % 3], is equal to((i % 3 + 1) as Float) within(tolerance))
				expect(tuple4[i % 4], is equal to((i % 4 + 1) as Float) within(tolerance))
			}
		})
	}
}

FloatTupleTest new() run() . free()
