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

IntPoint3DTest: class extends Fixture {
	point0 := IntPoint3D new (22, -3, 8)
	point1 := IntPoint3D new (12, 13, -8)
	point2 := IntPoint3D new (34, 10, 0)
	point3 := IntPoint3D new (10, 20, 0)
	init: func {
		tolerance := 1.0e-5f
		super("IntPoint3D")
		this add("fixture", func {
			expect(this point0 + this point1, is equal to(this point2))
		})
		this add("equality", func {
			point := IntPoint3D new()
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func {
			expect((this point0 + this point1) x, is equal to(this point2 x))
			expect((this point0 + this point1) y, is equal to(this point2 y))
			expect((this point0 + this point1) z, is equal to(this point2 z))
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to((IntPoint3D new()) x))
			expect((this point0 - this point0) y, is equal to((IntPoint3D new()) y))
			expect((this point0 - this point0) z, is equal to((IntPoint3D new()) z))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this point0) x, is equal to((-this point0) x))
			expect(((-1) * this point0) y, is equal to((-this point0) y))
			expect(((-1) * this point0) z, is equal to((-this point0) z))
		})
		this add("scalar division", func {
			expect((this point0 / (-1)) x, is equal to((-this point0) x))
			expect((this point0 / (-1)) y, is equal to((-this point0) y))
			expect((this point0 / (-1)) z, is equal to((-this point0) z))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22))
			expect(this point0 y, is equal to(-3))
			expect(this point0 z, is equal to(8))
		})
		this add("casting", func {
			value := "10, 20, 0"
			string := this point3 toString()
			expect(string, is equal to(value))
			string free()
			expect(IntPoint3D parse(value) x, is equal to(this point3 x))
			expect(IntPoint3D parse(value) y, is equal to(this point3 y))
			expect(IntPoint3D parse(value) z, is equal to(this point3 z))
		})
		this add("float casts", func {
			point := this point0 toFloatPoint3D()
			expect(point x, is equal to(22.0f) within(tolerance))
			expect(point y, is equal to(-3.0f) within(tolerance))
			expect(point z, is equal to(8.0f) within(tolerance))
		})
		this add("minimum maximum", func {
			max := this point0 maximum(this point1)
			min := this point0 minimum(this point1)
			expect(max x, is equal to(22))
			expect(max y, is equal to(13))
			expect(max z, is equal to(8))
			expect(min x, is equal to(12))
			expect(min y, is equal to(-3))
			expect(min z, is equal to(-8))
		})
		this add("scalar product", func {
			product := this point0 scalarProduct(this point1)
			expect(product, is equal to(161))
		})
		this add("clamp", func {
			result := this point1 clamp(this point0, this point2)
			expect(result x, is equal to(22))
			expect(result y, is equal to(10))
			expect(result z, is equal to(8))
		})
	}
}

IntPoint3DTest new() run() . free()
