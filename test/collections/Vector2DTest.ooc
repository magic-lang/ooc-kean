/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use collections

Vector2DTest: class extends Fixture {
	init: func {
		super("Vector2D")
		this add("count", func {
			vector2D := Vector2D<Int> new(8, 12)
			expect(vector2D width, is equal to(8))
			expect(vector2D height, is equal to(12))
			vector2D free()
		})
		this add("get and set operators", func {
			vector2D := Vector2D<Int> new(10, 20)
			for (y in 0 .. vector2D height)
				for (x in 0 .. vector2D width)
					expect(vector2D[x, y], is equal to(0))
			for (y in 0 .. vector2D height)
				for (x in 0 .. vector2D width)
					vector2D[x, y] = y * vector2D width + x
			for (y in 0 .. vector2D height)
				for (x in 0 .. vector2D width)
					expect(vector2D[x, y], is equal to(y * vector2D width + x))
			for (y in 0 .. vector2D height)
				for (x in 0 .. vector2D width)
					vector2D[x, y] = x + y * 2
			for (y in 0 .. vector2D height)
				for (x in 0 .. vector2D width)
					expect(vector2D[x, y], is equal to(x + y * 2))
			vector2D free()
		})
	}
}

Vector2DTest new() run() . free()
