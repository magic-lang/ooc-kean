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

FloatPoint2DTest: class extends Fixture {
	point0 := FloatPoint2D new (22.221f, -3.1f)
	point1 := FloatPoint2D new (12.221f, 13.1f)
	point2 := FloatPoint2D new (34.442f, 10.0f)
	point3 := FloatPoint2D new (10.0f, 20.0f)
	init: func {
		tolerance := 1.0e-5f
		super("FloatPoint2D")
		this add("fixture", func {
			expect(this point0 + this point1, is equal to(this point2) within(tolerance))
		})
		this add("equality", func {
			point := FloatPoint2D new()
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
			expect((this point0 - this point0) x, is equal to((FloatPoint2D new()) x))
			expect((this point0 - this point0) y, is equal to((FloatPoint2D new()) y))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this point0) x, is equal to((-this point0) x))
			expect(((-1) * this point0) y, is equal to((-this point0) y))
		})
		this add("scalar division", func {
			expect((this point0 / (-1)) x, is equal to((-this point0) x))
			expect((this point0 / (-1)) y, is equal to((-this point0) y))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22.221f))
			expect(this point0 y, is equal to(-3.1f))
		})
		this add("swap", func {
			result := this point0 swap()
			expect(result x, is equal to(this point0 y))
			expect(result y, is equal to(this point0 x))
		})
		this add("casting", func {
			value := "10.00, 20.00"
			string := this point3 toString()
			expect(string, is equal to(value))
			string free()
			expect(FloatPoint2D parse(value) x, is equal to(this point3 x))
			expect(FloatPoint2D parse(value) y, is equal to(this point3 y))
		})
		this add("polar 0", func {
			point := FloatPoint2D new()
			expect(point norm, is equal to(0))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 1", func {
			point := FloatPoint2D new(1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 2", func {
			point := FloatPoint2D new(0, 1)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(Float pi / 2.0f))
		})
		this add("polar 3", func {
			point := FloatPoint2D new(0, -5)
			expect(point norm, is equal to(5.0f))
			expect(point azimuth, is equal to(Float pi / -2.0f))
		})
		this add("polar 4", func {
			point := FloatPoint2D new(-1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(Float pi))
		})
		this add("polar 5", func {
			pointA := FloatPoint2D new(-3, 0)
			pointB := FloatPoint2D polar(pointA norm, pointA azimuth)
			expect(pointA distance(pointB), is equal to(0.0f) within(tolerance))
		})
		this add("angles", func {
			expect(FloatPoint2D basisX angle(FloatPoint2D basisX), is equal to(0.0f) within(tolerance))
			expect(FloatPoint2D basisX angle(FloatPoint2D basisY), is equal to(Float pi / 2.0f) within(tolerance))
			expect(FloatPoint2D basisX angle(-FloatPoint2D basisX), is equal to(Float pi) within(tolerance))
			expect(FloatPoint2D basisX angle(-FloatPoint2D basisY), is equal to(-(Float pi) / 2.0f) within(tolerance))
		})
		this add("minimum", func {
			expect((this point0 minimum(this point1)) x, is equal to((this point1) x))
			expect((this point0 minimum(this point1)) y, is equal to((this point0) y))
		})
		this add("maximum", func {
			expect((this point0 maximum(this point1)) x, is equal to((this point0) x))
			expect((this point0 maximum(this point1)) y, is equal to((this point1) y))
		})
		this add("int casts", func {
			point := this point3 toIntPoint2D()
			expect(point x, is equal to(10))
			expect(point y, is equal to(20))
		})
		this add("float casts", func {
			vector := this point3 toFloatVector2D()
			expect(vector x, is equal to(this point3 x))
			expect(vector y, is equal to(this point3 y))
		})
		this add("minimum maximum", func {
			max := this point0 maximum(this point1)
			min := this point0 minimum(this point1)
			expect(max x, is equal to(22.221f) within(tolerance))
			expect(max y, is equal to(13.1f) within(tolerance))
			expect(min x, is equal to(12.221f) within(tolerance))
			expect(min y, is equal to(-3.1f) within(tolerance))
		})
		this add("rounding", func {
			round := this point1 round()
			ceiling := this point1 ceiling()
			floor := this point1 floor()
			expect(round x, is equal to(12.0f) within(tolerance))
			expect(round y, is equal to(13.0f) within(tolerance))
			expect(ceiling x, is equal to(13.0f) within(tolerance))
			expect(ceiling y, is equal to(14.0f) within(tolerance))
			expect(floor x, is equal to(12.0f) within(tolerance))
			expect(floor y, is equal to(13.0f) within(tolerance))
		})
		this add("p norm", func {
			oneNorm := this point0 pNorm(1)
			euclideanNorm := this point0 pNorm(2)
			expect(oneNorm, is equal to(25.321f) within(tolerance))
			expect(euclideanNorm, is equal to(22.436f) within(0.01f))
		})
		this add("scalar product", func {
			expect(this point0 scalarProduct(this point1), is equal to (230.95f) within(0.01f))
		})
		this add("distance", func {
			distance := this point0 distance(this point1)
			expect(distance, is equal to(19.04f) within(0.01f))
		})
		this add("distanceSquared", func {
			distance := this point0 distanceSquared(this point1)
			expect(distance, is equal to(362.44f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this point1 clamp(this point0, this point2)
			expect(clamped x, is equal to(this point0 x) within(tolerance))
			expect(clamped y, is equal to(this point2 y) within(tolerance))
		})
		this add("interpolation", func {
			interpolate1 := FloatPoint2D mix(this point0, this point1, 0.0f)
			interpolate2 := FloatPoint2D mix(this point0, this point1, 0.5f)
			interpolate3 := FloatPoint2D mix(this point0, this point1, 1.0f)
			expect(interpolate1 x, is equal to(this point0 x) within(tolerance))
			expect(interpolate1 y, is equal to(this point0 y) within(tolerance))
			expect(interpolate2 x, is equal to(17.22f) within(0.01f))
			expect(interpolate2 y, is equal to(5.0f) within(0.01f))
			expect(interpolate3 x, is equal to(this point1 x) within(tolerance))
			expect(interpolate3 y, is equal to(this point1 y) within(tolerance))
		})
	}
}

FloatPoint2DTest new() run() . free()
