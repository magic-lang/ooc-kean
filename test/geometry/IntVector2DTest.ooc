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

IntVector2DTest: class extends Fixture {
	vector0 := IntVector2D new (22, -3)
	vector1 := IntVector2D new (12, 13)
	vector2 := IntVector2D new (34, 10)
	vector3 := IntVector2D new (10, 20)
	init: func {
		tolerance := 1.0e-5f
		super("IntVector2D")
		this add("fixture", func {
			expect(this vector0 + this vector1, is equal to(this vector2))
		})
		this add("equality", func {
			point := IntVector2D new()
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func {
			expect((this vector0 + this vector1) x, is equal to(this vector2 x))
			expect((this vector0 + this vector1) y, is equal to(this vector2 y))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) x, is equal to((IntVector2D new()) x))
			expect((this vector0 - this vector0) y, is equal to((IntVector2D new()) y))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this vector0) x, is equal to((-this vector0) x))
			expect(((-1) * this vector0) y, is equal to((-this vector0) y))
		})
		this add("scalar division", func {
			expect((this vector0 / (-1)) x, is equal to((-this vector0) x))
			expect((this vector0 / (-1)) y, is equal to((-this vector0) y))
		})
		this add("get values", func {
			expect(this vector0 x, is equal to(22))
			expect(this vector0 y, is equal to(-3))
		})
		this add("swap", func {
			result := this vector0 swap()
			expect(result x, is equal to(this vector0 y))
			expect(result y, is equal to(this vector0 x))
		})
		this add("casting", func {
			value := "10, 20"
			string := this vector3 toString()
			expect(string, is equal to(value))
			string free()
			expect(IntVector2D parse(value) x, is equal to(this vector3 x))
			expect(IntVector2D parse(value) y, is equal to(this vector3 y))
		})
		this add("float casts", func {
			vector := this vector0 toFloatVector2D()
			expect(vector x, is equal to(22.0f) within(tolerance))
			expect(vector y, is equal to(-3.0f) within(tolerance))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (225))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max x, is equal to(22))
			expect(max y, is equal to(13))
			expect(min x, is equal to(12))
			expect(min y, is equal to(-3))
		})
		this add("clamp", func {
			result := this vector1 clamp(this vector0, this vector2)
			expect(result x, is equal to(22))
			expect(result y, is equal to(10))
		})
		this add("polar", func {
			sqrttwo := IntVector2D polar(1.415f, 0.785f)
			expect(sqrttwo x, is equal to(1))
			expect(sqrttwo y, is equal to(1))
		})
		this add("area, square, hasZeroArea", func {
			rectangle := IntVector2D new(10, 20)
			square := IntVector2D new(5, 5)
			empty := IntVector2D new()
			expect(rectangle area, is equal to(200))
			expect(square square, is true)
			expect(rectangle square, is false)
			expect(empty hasZeroArea, is true)
			expect(square hasZeroArea, is false)
			expect(empty area, is equal to(0))
		})
	}
}

IntVector2DTest new() run() . free()
