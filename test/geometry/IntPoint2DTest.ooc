/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base
use geometry

IntPoint2DTest: class extends Fixture {
	point0 := IntPoint2D new (22, -3)
	point1 := IntPoint2D new (12, 13)
	point2 := IntPoint2D new (34, 10)
	point3 := IntPoint2D new (10, 20)
	init: func {
		tolerance := 1.0e-5f
		super("IntPoint2D")
		this add("fixture", func {
			expect(this point0 + this point1, is equal to(this point2))
		})
		this add("equality", func {
			point := IntPoint2D new()
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func {
			expect((this point0 + this point1) x, is equal to(this point2 x))
			expect((this point0 + this point1) y, is equal to(this point2 y))
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to((IntPoint2D new()) x))
			expect((this point0 - this point0) y, is equal to((IntPoint2D new()) y))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22))
			expect(this point0 y, is equal to(-3))
		})
		this add("swap", func {
			result := this point0 swap()
			expect(result x, is equal to(this point0 y))
			expect(result y, is equal to(this point0 x))
		})
		this add("casting", func {
			value := "10, 20"
			string := this point3 toString()
			expect(string, is equal to(value))
			string free()
			expect(IntPoint2D parse(value) x, is equal to(this point3 x))
			expect(IntPoint2D parse(value) y, is equal to(this point3 y))
		})
		this add("float casts", func {
			point := this point0 toFloatPoint2D()
			expect(point x, is equal to(22.0f) within(tolerance))
			expect(point y, is equal to(-3.0f) within(tolerance))
		})
		this add("minimum maximum", func {
			max := this point0 maximum(this point1)
			min := this point0 minimum(this point1)
			expect(max x, is equal to(22))
			expect(max y, is equal to(13))
			expect(min x, is equal to(12))
			expect(min y, is equal to(-3))
		})
		this add("scalar product", func {
			product := this point0 scalarProduct(this point1)
			expect(product, is equal to(225))
		})
		this add("clamp", func {
			result := this point1 clamp(this point0, this point2)
			expect(result x, is equal to(this point0 x))
			expect(result y, is equal to(this point2 y))
		})
		this add("distance", func {
			distance := this point0 distance(this point1)
			expect(distance, is equal to(18.87f) within(0.01f))
		})
	}
}

IntPoint2DTest new() run() . free()
