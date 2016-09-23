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

FloatVector3DTest: class extends Fixture {
	vector0 := FloatVector3D new (22.0f, -3.0f, 10.0f)
	vector1 := FloatVector3D new (12.0f, 13.0f, 20.0f)
	vector2 := FloatVector3D new (34.0f, 10.0f, 30.0f)
	vector3 := FloatVector3D new (10.0f, 20.0f, 30.0f)
	vector4 := FloatVector3D new (10.1f, 20.7f, 30.3f)
	init: func {
		tolerance := 1.0e-4f
		super("FloatVector3D")
		this add("fixture", func {
			expect(this vector0 + this vector1, is equal to(this vector2) within(tolerance))
		})
		this add("norm", func {
			expect(this vector0 norm, is equal to(593.0f sqrt()) within(tolerance))
			expect(this vector0 norm, is equal to(this vector0 scalarProduct(this vector0) sqrt()) within(tolerance))
		})
		this add("volume", func {
			expect(this vector3 volume, is equal to(6000.0f) within(tolerance))
		})
		this add("scalar product", func {
			size := FloatVector3D new()
			expect(this vector0 scalarProduct(size), is equal to(0.0f) within(tolerance))
			expect(this vector0 scalarProduct(this vector1), is equal to(425.0f) within(tolerance))
		})
		this add("vector product", func {
			expect(this vector0 vectorProduct(this vector1) x, is equal to(-190.0f) within(tolerance))
			expect(this vector0 vectorProduct(this vector1) y, is equal to(-320.0f) within(tolerance))
			expect(this vector0 vectorProduct(this vector1) z, is equal to(322.0f) within(tolerance))
		})
		this add("equality", func {
			size := FloatVector3D new()
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == size, is false)
			expect(size == size, is true)
			expect(size == this vector0, is false)
		})
		this add("addition", func {
			expect((this vector0 + this vector1) x, is equal to(this vector2 x))
			expect((this vector0 + this vector1) y, is equal to(this vector2 y))
			expect((this vector0 + this vector1) z, is equal to(this vector2 z))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) x, is equal to((FloatVector3D new()) x))
			expect((this vector0 - this vector0) y, is equal to((FloatVector3D new()) y))
			expect((this vector0 - this vector0) z, is equal to((FloatVector3D new()) z))
		})
		this add("get values", func {
			expect(this vector0 x, is equal to(22.0f))
			expect(this vector0 y, is equal to(-3.0f))
			expect(this vector0 z, is equal to(10.0f))
		})
		this add("casting", func {
			value := "10.00, 20.00, 30.00"
			string := this vector3 toString()
			expect(string, is equal to(value))
			string free()
			expect(FloatVector3D parse(value) x, is equal to(this vector3 x))
			expect(FloatVector3D parse(value) y, is equal to(this vector3 y))
			expect(FloatVector3D parse(value) z, is equal to(this vector3 z))
		})
		this add("int casts", func {
			vector := this vector0 toIntVector3D()
			expect(vector x, is equal to(22))
			expect(vector y, is equal to(-3))
			expect(vector z, is equal to(10))
		})
		this add("float casts", func {
			point := this vector0 toFloatPoint3D()
			expect(point x, is equal to(this vector0 x) within(tolerance))
			expect(point y, is equal to(this vector0 y) within(tolerance))
			expect(point z, is equal to(this vector0 z) within(tolerance))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max x, is equal to(22.0f) within(tolerance))
			expect(max y, is equal to(13.0f) within(tolerance))
			expect(max z, is equal to(20.0f) within(tolerance))
			expect(min x, is equal to(12.0f) within(tolerance))
			expect(min y, is equal to(-3.0f) within(tolerance))
			expect(min z, is equal to(10.0f) within(tolerance))
		})
		this add("rounding", func {
			round := this vector4 round()
			ceiling := this vector4 ceiling()
			floor := this vector4 floor()
			expect(round x, is equal to(10.0f) within(tolerance))
			expect(round y, is equal to(21.0f) within(tolerance))
			expect(round z, is equal to(30.0f) within(tolerance))
			expect(ceiling x, is equal to(11.0f) within(tolerance))
			expect(ceiling y, is equal to(21.0f) within(tolerance))
			expect(ceiling z, is equal to(31.0f) within(tolerance))
			expect(floor x, is equal to(10.0f) within(tolerance))
			expect(floor y, is equal to(20.0f) within(tolerance))
			expect(floor z, is equal to(30.0f) within(tolerance))
		})
		this add("p norm", func {
			oneNorm := this vector0 pNorm(1.0f)
			euclideanNorm := this vector0 pNorm(2.0f)
			expect(oneNorm, is equal to(35.0f) within(tolerance))
			expect(euclideanNorm, is equal to(24.352f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this vector1 clamp(this vector0, this vector2)
			expect(clamped x, is equal to(22.0f) within(tolerance))
			expect(clamped y, is equal to(10.0f) within(tolerance))
			expect(clamped z, is equal to(20.0f) within(tolerance))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (425.0f) within(tolerance))
		})
		this add("interpolation", func {
			interpolate1 := FloatVector3D mix(this vector0, this vector1, 0.0f)
			interpolate2 := FloatVector3D mix(this vector0, this vector1, 0.5f)
			interpolate3 := FloatVector3D mix(this vector0, this vector1, 1.0f)
			expect(interpolate1 x, is equal to(this vector0 x) within(tolerance))
			expect(interpolate1 y, is equal to(this vector0 y) within(tolerance))
			expect(interpolate1 z, is equal to(this vector0 z) within(tolerance))
			expect(interpolate2 x, is equal to(17.0f) within(0.01f))
			expect(interpolate2 y, is equal to(5.0f) within(0.01f))
			expect(interpolate2 z, is equal to(15.0f) within(0.01f))
			expect(interpolate3 x, is equal to(this vector1 x) within(tolerance))
			expect(interpolate3 y, is equal to(this vector1 y) within(tolerance))
			expect(interpolate3 z, is equal to(this vector1 z) within(tolerance))
		})
		this add("angle and distance", func {
			first := FloatVector3D new(2.0f, -3.0f, 5.0f)
			second := FloatVector3D new(5.0f, 3.0f, -7.0f)
			expect(first angle(second), is equal to(2.221f) within(0.01f))
			expect(first distance(second), is equal to(13.74f) within(0.01f))
		})
		this add("norm, hasZeroVolume", func {
			empty := FloatVector3D new()
			expect(this vector0 norm, is equal to(24.35f) within(0.01f))
			expect(empty hasZeroVolume, is true)
			expect(empty volume, is equal to(0.0f) within(tolerance))
			expect(this vector0 hasZeroVolume, is false)
			almostZero := (0.1 + 0.1 + 0.1) - 0.3
			empty = FloatVector3D new(almostZero, almostZero, 0.1f)
			expect(empty hasZeroVolume, is true)
		})
		this add("azimuth", func {
			myvector := FloatVector3D new(1.0, 5.5, 0.1)
			expect(myvector azimuth, is equal to(5.5f atan2(1.0f)) within(tolerance))
		})
		this add("limitLength", func {
			vector := FloatVector3D new(1.f, 1.f, 1.f) limitLength(0.75f)
			expect(vector norm, is equal to(0.75f) within(tolerance))
			vector = vector limitLength(0.8f)
			expect(vector norm, is equal to(0.75f) within(tolerance))
			vector = vector * 2.309401f
			expect(vector x, is equal to(1.f) within(0.01f))
			expect(vector y, is equal to(1.f) within(0.01f))
			expect(vector z, is equal to(1.f) within(0.01f))
		})
	}
}

FloatVector3DTest new() run() . free()
