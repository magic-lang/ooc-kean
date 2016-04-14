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

FloatVector2DTest: class extends Fixture {
	vector0 := FloatVector2D new (22.221f, -3.1f)
	vector1 := FloatVector2D new (12.221f, 13.1f)
	vector2 := FloatVector2D new (34.442f, 10.0f)
	vector3 := FloatVector2D new (10.0f, 20.0f)
	init: func {
		tolerance := 1.0e-4f
		super("FloatVector2D")
		this add("fixture", func {
			expect(this vector0 + this vector1, is equal to(this vector2) within(tolerance))
		})
		this add("equality", func {
			point := FloatVector2D new()
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
			expect((this vector0 - this vector0) x, is equal to(FloatVector2D new() x))
			expect((this vector0 - this vector0) y, is equal to(FloatVector2D new() y))
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
			expect(this vector0 x, is equal to(22.221f))
			expect(this vector0 y, is equal to(-3.1f))
		})
		this add("swap", func {
			result := this vector0 swap()
			expect(result x, is equal to(this vector0 y) within(tolerance))
			expect(result y, is equal to(this vector0 x) within(tolerance))
		})
		this add("casting", func {
			value := t"10.00, 20.00"
			expect(this vector3 toString(), is equal to(value toString()))
			expect(FloatVector2D parse(value) x, is equal to(this vector3 x))
			expect(FloatVector2D parse(value) y, is equal to(this vector3 y))
		})
		this add("float casts", func {
			point := this vector3 toFloatPoint2D()
			expect(point x, is equal to(this vector3 x) within(tolerance))
			expect(point y, is equal to(this vector3 y) within(tolerance))
		})
		this add("polar 0", func {
			point := FloatVector2D new()
			expect(point norm, is equal to(0))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 1", func {
			point := FloatVector2D new(1, 0)
			expect(point norm, is equal to(1.0f) within(tolerance))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 2", func {
			point := FloatVector2D new(0, 1)
			expect(point norm, is equal to(1.0f) within(tolerance))
			expect(point azimuth, is equal to(Float pi / 2.0f) within(tolerance))
		})
		this add("polar 3", func {
			point := FloatVector2D new(0, -5)
			expect(point norm, is equal to(5.0f) within(tolerance))
			expect(point azimuth, is equal to(Float pi / -2.0f) within(tolerance))
		})
		this add("polar 4", func {
			point := FloatVector2D new(-1, 0)
			expect(point norm, is equal to(1.0f) within(tolerance))
			expect(point azimuth, is equal to(Float pi) within(tolerance))
		})
		this add("polar 5", func {
			point := FloatVector2D new(-3, 0)
			point2 := FloatVector2D polar(point norm, point azimuth)
			expect(point distance(point2), is equal to(0.0f) within(tolerance))
		})
		this add("angles", func {
			expect(FloatVector2D basisX angle(FloatVector2D basisX), is equal to(0.0f) within(tolerance))
			expect(FloatVector2D basisX angle(FloatVector2D basisY), is equal to(Float pi / 2.0f) within(tolerance))
			expect(FloatVector2D basisX angle(-FloatVector2D basisX), is equal to(Float pi) within(tolerance))
			expect(FloatVector2D basisX angle(-FloatVector2D basisY), is equal to(-(Float pi) / 2.0f) within(tolerance))
		})
		this add("int casts", func {
			vector := this vector0 toIntVector2D()
			expect(vector x, is equal to(22))
			expect(vector y, is equal to(-3))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max x, is equal to(22.221f) within(tolerance))
			expect(max y, is equal to(13.1f) within(tolerance))
			expect(min x, is equal to(12.221f) within(tolerance))
			expect(min y, is equal to(-3.1f) within(tolerance))
		})
		this add("rounding", func {
			round := this vector1 round()
			ceiling := this vector1 ceiling()
			floor := this vector1 floor()
			expect(round x, is equal to(12.0f) within(tolerance))
			expect(round y, is equal to(13.0f) within(tolerance))
			expect(ceiling x, is equal to(13.0f) within(tolerance))
			expect(ceiling y, is equal to(14.0f) within(tolerance))
			expect(floor x, is equal to(12.0f) within(tolerance))
			expect(floor y, is equal to(13.0f) within(tolerance))
		})
		this add("p norm", func {
			oneNorm := this vector0 pNorm(1.0f)
			euclideanNorm := this vector0 pNorm(2.0f)
			expect(oneNorm, is equal to(25.321f) within(tolerance))
			expect(euclideanNorm, is equal to(22.436f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this vector1 clamp(this vector0, this vector2)
			expect(clamped x, is equal to(22.221f) within(tolerance))
			expect(clamped y, is equal to(10.0f) within(tolerance))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (230.95f) within(0.01f))
		})
		this add("interpolation", func {
			interpolate1 := FloatVector2D linearInterpolation(this vector0, this vector1, 0.0f)
			interpolate2 := FloatVector2D linearInterpolation(this vector0, this vector1, 0.5f)
			interpolate3 := FloatVector2D linearInterpolation(this vector0, this vector1, 1.0f)
			expect(interpolate1 x, is equal to(this vector0 x) within(tolerance))
			expect(interpolate1 y, is equal to(this vector0 y) within(tolerance))
			expect(interpolate2 x, is equal to(17.22f) within(0.01f))
			expect(interpolate2 y, is equal to(5.0f) within(0.01f))
			expect(interpolate3 x, is equal to(this vector1 x) within(tolerance))
			expect(interpolate3 y, is equal to(this vector1 y) within(tolerance))
		})
		this add("area, length, hasZeroArea", func {
			empty := FloatVector2D new()
			expect(this vector0 area, is equal to(-68.89f) within(0.01f))
			expect(this vector0 length, is equal to(22.44f) within(0.01f))
			expect(empty hasZeroArea, is true)
			expect(empty area, is equal to(0.0f) within(tolerance))
			expect(this vector1 hasZeroArea, is false)
			almostZero := (0.1 + 0.1 + 0.1) - 0.3
			empty = FloatVector2D new(almostZero, 0.1f)
			expect(empty hasZeroArea, is true)
		})
		this add("toText", func {
			text := FloatVector2D new(1.0f, 2.0f) toText() take()
			expect(text, is equal to(t"1.00, 2.00"))
			text free()
		})
		this add("limitLength", func {
			vector := FloatVector2D new(1.f, 1.f) limitLength(0.75f)
			expect(vector norm, is equal to(0.75f) within(tolerance))
			vector = vector limitLength(0.8f)
			expect(vector norm, is equal to(0.75f) within(tolerance))
			vector = vector * 1.88612f
			expect(vector x, is equal to(1.f) within(0.01f))
			expect(vector y, is equal to(1.f) within(0.01f))
		})
	}
}

FloatVector2DTest new() run() . free()
