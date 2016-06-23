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

IntVector3DTest: class extends Fixture {
	vector0 := IntVector3D new (22, -3, 8)
	vector1 := IntVector3D new (12, 13, -8)
	vector2 := IntVector3D new (34, 10, 0)
	vector3 := IntVector3D new (10, 20, 0)
	init: func {
		tolerance := 1.0e-5f
		super("IntVector3D")
		this add("fixture", func {
			expect(this vector0 + this vector1, is equal to(this vector2))
		})
		this add("equality", func {
			point := IntVector3D new()
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func {
			expect((this vector0 + this vector1) x, is equal to(this vector2 x))
			expect((this vector0 + this vector1) y, is equal to(this vector2 y))
			expect((this vector0 + this vector1) z, is equal to(this vector2 z))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) x, is equal to((IntVector3D new()) x))
			expect((this vector0 - this vector0) y, is equal to((IntVector3D new()) y))
			expect((this vector0 - this vector0) z, is equal to((IntVector3D new()) z))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this vector0) x, is equal to((-this vector0) x))
			expect(((-1) * this vector0) y, is equal to((-this vector0) y))
			expect(((-1) * this vector0) z, is equal to((-this vector0) z))
		})
		this add("scalar division", func {
			expect((this vector0 / (-1)) x, is equal to((-this vector0) x))
			expect((this vector0 / (-1)) y, is equal to((-this vector0) y))
			expect((this vector0 / (-1)) z, is equal to((-this vector0) z))
		})
		this add("get values", func {
			expect(this vector0 x, is equal to(22))
			expect(this vector0 y, is equal to(-3))
			expect(this vector0 z, is equal to(8))
		})
		this add("casting", func {
			value := "10, 20, 0"
			string := this vector3 toString()
			expect(string, is equal to(value))
			string free()
			expect(IntVector3D parse(value) x, is equal to(this vector3 x))
			expect(IntVector3D parse(value) y, is equal to(this vector3 y))
			expect(IntVector3D parse(value) z, is equal to(this vector3 z))
		})
		this add("float casts", func {
			vector := this vector0 toFloatVector3D()
			expect(vector x, is equal to(22.0f) within(tolerance))
			expect(vector y, is equal to(-3.0f) within(tolerance))
			expect(vector z, is equal to(8.0f) within(tolerance))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (161))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max x, is equal to(22))
			expect(max y, is equal to(13))
			expect(max z, is equal to(8))
			expect(min x, is equal to(12))
			expect(min y, is equal to(-3))
			expect(min z, is equal to(-8))
		})
		this add("clamp", func {
			result := this vector1 clamp(this vector0, this vector2)
			expect(result x, is equal to(22))
			expect(result y, is equal to(10))
			expect(result z, is equal to(8))
		})
		this add("volume, hasZeroVolume", func {
			empty := IntVector3D new()
			expect(empty hasZeroVolume, is true)
			expect(this vector1 hasZeroVolume, is false)
			expect(this vector1 volume, is equal to(-1248))
			expect(empty volume, is equal to(0))
		})
	}
}

IntVector3DTest new() run() . free()
