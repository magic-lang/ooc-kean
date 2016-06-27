/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use unit
use math
use geometry

QuaternionTest: class extends Fixture {
	Debug initialize(func (s: String) { println(s) })
	quaternion0 := Quaternion new(33.0f, 10.0f, -12.0f, 54.5f)
	quaternion1 := Quaternion new(10.0f, 17.0f, -10.0f, 14.5f)
	quaternion2 := Quaternion new(43.0f, 27.0f, -22.0f, 69.0f)
	quaternion3 := Quaternion new(-750.25f, 1032.0f, 331.5f, 1127.5f)
	quaternion4 := Quaternion new(10.0f, 17.0f, -10.0f, 14.5f)
	quaternion5 := Quaternion new(1.0f, 2.0f, 3.0f, 4.0f)
	quaternion6 := Quaternion new(-1.0f, -2.0f, -3.0f, -4.0f)
	quaternion7 := Quaternion new(1.0f, 0.0f, 0.0f, 0.0f)
	quaternion8 := Quaternion new(0.1f, 0.0f, 0.0f, 1.0f)
	quaternion9 := Quaternion new(0.2f, 0.0f, 1.0f, 0.0f)
	quaternion10 := Quaternion new(0.12f, 0.4472136f, 0.8366f, 0.316227766f)
	point0 := FloatPoint3D new(22.221f, -3.1f, 10.0f)
	point1 := FloatPoint3D new(12.221f, 13.1f, 20.0f)
	quaternionList := VectorList<Quaternion> new()
	init: func {
		super("Quaternion")
		tolerance := 0.0001f
		this add("fixture", func {
			expect(this quaternion0 + this quaternion1, is equal to(this quaternion2) within(tolerance))
		})
		this add("comparison", func {
			expect(this quaternion1 == this quaternion4)
			expect(this quaternion2 == this quaternion3, is false)
			expect(this quaternion3 != this quaternion4)
			expect(this quaternion1 != this quaternion4, is false)
		})
		this add("properties", func {
			expect(this quaternion7 isIdentity)
			expect((this quaternion7 - this quaternion7) isZero)
		})
		this add("addition", func {
			expect(this quaternion0 + this quaternion1 == this quaternion2)
		})
		this add("subtraction", func {
			expect(this quaternion0 - this quaternion0 == Quaternion new())
		})
		this add("multiplication", func {
			expect(this quaternion0 * this quaternion1 == this quaternion3)
		})
		this add("dot product", func {
			expect(this quaternion0 dotProduct(this quaternion1), is equal to(1410.25f) within(tolerance))
		})
		this add("scalarMultiplication", func {
			expect((-1.0f) * this quaternion0 == -this quaternion0)
		})
		this add("norm", func {
			expect(this quaternion0 norm as Float, is equal to(65.5991592f))
		})
		this add("inverse", func {
			inverse := this quaternion2 inverse
			product := this quaternion2 * inverse
			expect(product real as Float, is equal to(1.0f) within(tolerance))
			expect(product x as Float, is equal to(0.0f) within(tolerance))
			expect(product y as Float, is equal to(0.0f) within(tolerance))
			expect(product z as Float, is equal to(0.0f) within(tolerance))
		})
		this add("conjugate", func {
			conjugate := this quaternion5 conjugate
			expect(conjugate w == this quaternion5 w)
			expect(conjugate x == -this quaternion5 x)
			expect(conjugate y == -this quaternion5 y)
			expect(conjugate z == -this quaternion5 z)
		})
		this add("normalized", func {
			normalized := this quaternion0 normalized as Quaternion
			expect(Quaternion new(1, 0, 0, 0) normalized == Quaternion identity)
			expect(normalized w, is equal to(0.5030552f) within(tolerance))
			expect(normalized x, is equal to(0.1524409f) within(tolerance))
			expect(normalized y, is equal to(-0.1829291f) within(tolerance))
			expect(normalized z, is equal to(0.8308033f) within(tolerance))
		})
		this add("actionOnVector", func {
			direction := FloatVector3D new(1.0f, 1.0f, 1.0f)
			quaternion := Quaternion createFromAxisAngle(direction, 120.0f toRadians())
			point1 := FloatPoint3D new(5.0f, 6.0f, 7.0f)
			point2 := FloatPoint3D new(7.0f, 5.0f, 6.0f)
			expect((quaternion * point1) distance(point2), is equal to(0.0f) within(tolerance))
		})
		this add("angle", func {
			direction := FloatVector3D new(1.0f, 1.0f, 1.0f)
			quaternionA := Quaternion createFromAxisAngle(direction, 20.0f toRadians())
			quaternionB := Quaternion createFromAxisAngle(direction, 45.0f toRadians())
			angle := (quaternionA angle(quaternionB)) toDegrees()
			expect(angle, is equal to(25.0f) within(tolerance))
		})
		this add("exponentialLogarithm", func {
			roll := 20.0f toRadians()
			pitch := (-30.0f) toRadians()
			yaw := 45.0f toRadians()
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			//expLog := quaternion exponential logarithm
			exp := (quaternion exponential)
			expLog := exp logarithm
			expect(expLog real, is equal to(quaternion real) within(tolerance))
		})
		this add("logarithmExponential", func {
			roll := 20.0f toRadians()
			pitch := (-30.0f) toRadians()
			yaw := 45.0f toRadians()
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			//logExp := quaternion logarithm exponential
			log := quaternion logarithm
			logExp := log exponential
			expect(logExp real, is equal to(quaternion real) within(tolerance))
		})
		this add("exponentialLogarithmDistance", func {
			roll := 20.0f toRadians()
			pitch := (-30.0f) toRadians()
			yaw := 45.0f toRadians()
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			//expLog := quaternion exponential logarithm
			exp := quaternion exponential
			expLog := exp logarithm
			expect(expLog imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
		})
		this add("logarithmExponentialDistance", func {
			roll := 20.0f toRadians()
			pitch := (-30.0f) toRadians()
			yaw := 45.0f toRadians()
			quaternion := Quaternion createRotationZ(yaw) * Quaternion createRotationY(pitch) * Quaternion createRotationX(roll)
			//logExp := quaternion exponential logarithm
			exp := quaternion exponential
			logExp := exp logarithm
			expect(logExp imaginary distance(quaternion imaginary), is equal to(0.0f) within(tolerance))
		})
		this add("power", func {
			quaternion := Quaternion createRotationX(Float pi / 2.f)
			halfQuaternion := quaternion power(0.5f)
			expect(halfQuaternion rotationX, is equal to(Float pi / 4.f) within(tolerance))
			quaternion = Quaternion createRotationY(Float pi / 2.f)
			quarterQuaternion := quaternion power(0.25f)
			expect(quarterQuaternion rotationY, is equal to(Float pi / 8.f) within(tolerance))
			quaternion = Quaternion createRotationZ(Float pi / 2.f)
			doubleQuaternion := quaternion power(2.0f)
			expect(doubleQuaternion rotationZ, is equal to(Float pi) within(tolerance))
		})
		this add("toFloatTransform3D_1", func {
			// Results from http://www.energid.com/resources/quaternion-calculator/
			float3DTransform := Quaternion new(0.1f, 1.0f, 0.0f, 0.0f) toFloatTransform3D()
			expect(float3DTransform a, is equal to(1.0f) within(tolerance))
			expect(float3DTransform b, is equal to(0.0f) within(tolerance))
			expect(float3DTransform c, is equal to(0.0f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(0.0f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.980198f) within(tolerance))
			expect(float3DTransform g, is equal to(0.1980198f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.0f) within(tolerance))
			expect(float3DTransform j, is equal to(-0.1980198f) within(tolerance))
			expect(float3DTransform k, is equal to(-0.980198f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("toFloatTransform3D_2", func {
			float3DTransform := Quaternion new(0.543f, 0.123f, 0.325f, 0.876f) toFloatTransform3D()
			expect(float3DTransform a, is equal to(-0.475937f) within(tolerance))
			expect(float3DTransform b, is equal to(0.871770f) within(tolerance))
			expect(float3DTransform c, is equal to(-0.116193f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(-0.736603f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.322940f) within(tolerance))
			expect(float3DTransform g, is equal to(0.594244f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.480521f) within(tolerance))
			expect(float3DTransform j, is equal to(0.368411f) within(tolerance))
			expect(float3DTransform k, is equal to(0.795848f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("toFloatTransform3D_3", func {
			float3DTransform := this quaternion3 toFloatTransform3D()
			expect(float3DTransform a, is equal to(0.082003f) within(tolerance))
			expect(float3DTransform b, is equal to(-0.334856f) within(tolerance))
			expect(float3DTransform c, is equal to(0.938694f) within(tolerance))
			expect(float3DTransform d, is equal to(0.0f) within(tolerance))
			expect(float3DTransform e, is equal to(0.789629f) within(tolerance))
			expect(float3DTransform f, is equal to(-0.552837f) within(tolerance))
			expect(float3DTransform g, is equal to(-0.266192f) within(tolerance))
			expect(float3DTransform h, is equal to(0.0f) within(tolerance))
			expect(float3DTransform i, is equal to(0.608081f) within(tolerance))
			expect(float3DTransform j, is equal to(0.763048f) within(tolerance))
			expect(float3DTransform k, is equal to(0.219078f) within(tolerance))
			expect(float3DTransform l, is equal to(0.0f) within(tolerance))
			expect(float3DTransform m, is equal to(0.0f) within(tolerance))
			expect(float3DTransform n, is equal to(0.0f) within(tolerance))
			expect(float3DTransform o, is equal to(0.0f) within(tolerance))
			expect(float3DTransform p, is equal to(1.0f) within(tolerance))
		})
		this add("fromFloatTransform3D: identity", func {
			// Identity matrix
			matrix := FloatTransform3D new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w == 1.0f)
			expect(quaternion x == 0.0f)
			expect(quaternion y == 0.0f)
			expect(quaternion z == 0.0f)
		})
		this add("fromFloatTransform3D: trace > 0.0f", func {
			matrix := FloatTransform3D new(1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.866025f) within(tolerance))
			expect(quaternion x, is equal to(0.288675f) within(tolerance))
			expect(quaternion y, is equal to(0.577350f) within(tolerance))
			expect(quaternion z, is equal to(0.0f) within(tolerance))
		})
		this add("fromFloatTransform3D: matrix a > matrix e && matrix a > matrix i", func {
			matrix := FloatTransform3D new(1.0f, 1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 0.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.0f) within(tolerance))
			expect(quaternion x, is equal to(1.0f) within(tolerance))
			expect(quaternion y, is equal to(0.5f) within(tolerance))
			expect(quaternion z, is equal to(-0.25f) within(tolerance))
		})
		this add("fromFloatTransform3D: matrix e > matrix i", func {
			matrix := FloatTransform3D new(0.0f, 1.0f, -1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(0.707106f) within(tolerance))
			expect(quaternion x, is equal to(0.707106f) within(tolerance))
			expect(quaternion y, is equal to(0.707106f) within(tolerance))
			expect(quaternion z, is equal to(0.353553f) within(tolerance))
		})
		this add("fromFloatTransform3D: else", func {
			matrix := FloatTransform3D new(-1.0f, 0.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f)
			quaternion := Quaternion new(matrix)
			expect(quaternion w, is equal to(-0.35355339059327373f) within(tolerance))
			expect(quaternion x, is equal to(-0.353553f) within(tolerance))
			expect(quaternion y, is equal to(-0.353553f) within(tolerance))
			expect(quaternion z, is equal to(0.707106f) within(tolerance))
		})
		this add("fromFloatTransform3D_1", func {
			matrix := this quaternion0 toFloatTransform3D()
			quaternion := Quaternion new(matrix)
			normalized := this quaternion0 normalized as Quaternion
			expect(quaternion w, is equal to(normalized w) within(tolerance))
			expect(quaternion x, is equal to(normalized x) within(tolerance))
			expect(quaternion y, is equal to(normalized y) within(tolerance))
			expect(quaternion z, is equal to(normalized z) within(tolerance))
		})
		this add("fromFloatTransform3D_2", func {
			matrix := this quaternion3 toFloatTransform3D()
			quaternion := Quaternion new(matrix)
			normalized := this quaternion3 normalized as Quaternion
			expect(quaternion w, is equal to(normalized w) within(tolerance))
			expect(quaternion x, is equal to(normalized x) within(tolerance))
			expect(quaternion y, is equal to(normalized y) within(tolerance))
			expect(quaternion z, is equal to(normalized z) within(tolerance))
		})
		this add("axisAngle_1", func {
			axis := FloatVector3D new(1.f, 0.f, 0.f)
			angle := Float pi / 2.f
			quaternion := Quaternion createFromAxisAngle(axis, angle)
			expect(quaternion w, is equal to(0.70710678118f) within(tolerance))
			expect(quaternion x, is equal to(0.70710678118f) within(tolerance))
			expect(quaternion y, is equal to(0.f) within(tolerance))
			expect(quaternion z, is equal to(0.f) within(tolerance))
		})
		this add("axisAngle_2", func {
			quaternion := Quaternion new(2.f sqrt() / 2.f, 2.f sqrt() / 2.f, 0.f, 0.f)
			(axis, angle) := quaternion toAxisAngle()
			expect(angle, is equal to(1.57079632679f) within(tolerance))
			expect(axis x, is equal to(1.f) within(tolerance))
			expect(axis y, is equal to(0.f) within(tolerance))
			expect(axis z, is equal to(0.f) within(tolerance))
		})
		this add("axisAngle_3", func {
			axis := FloatVector3D new(1.f, 2.f, 3.f)
			angle := 0.5f
			quaternionA := Quaternion createFromAxisAngle(axis, angle)
			(axis, angle) = quaternionA toAxisAngle()
			quaternionB := Quaternion createFromAxisAngle(axis, angle)
			expect(quaternionA w, is equal to(quaternionB w) within(tolerance))
			expect(quaternionA x, is equal to(quaternionB x) within(tolerance))
			expect(quaternionA y, is equal to(quaternionB y) within(tolerance))
			expect(quaternionA z, is equal to(quaternionB z) within(tolerance))
		})
		this add("eulerVector_1", func {
			vector := FloatVector3D new(Float pi / 2.f, 0.f, 0.f)
			quaternion := Quaternion createFromEulerVector(vector)
			expect(quaternion w, is equal to(0.70710678118f) within(tolerance))
			expect(quaternion x, is equal to(0.70710678118f) within(tolerance))
			expect(quaternion y, is equal to(0.f) within(tolerance))
			expect(quaternion z, is equal to(0.f) within(tolerance))
		})
		this add("eulerVector_2", func {
			quaternion := Quaternion new(2.f sqrt() / 2.f, 2.f sqrt() / 2.f, 0.f, 0.f)
			vector := quaternion toEulerVector()
			expect(vector x, is equal to(1.57079632679f) within(tolerance))
			expect(vector y, is equal to(0.f) within(tolerance))
			expect(vector z, is equal to(0.f) within(tolerance))
		})
		this add("eulerVector_3", func {
			vector := FloatVector3D new(1.f, 2.f, 3.f)
			quaternionA := Quaternion createFromEulerVector(vector)
			vector = quaternionA toEulerVector()
			quaternionB := Quaternion createFromEulerVector(vector)
			expect(quaternionA w, is equal to(quaternionB w) within(tolerance))
			expect(quaternionA x, is equal to(quaternionB x) within(tolerance))
			expect(quaternionA y, is equal to(quaternionB y) within(tolerance))
			expect(quaternionA z, is equal to(quaternionB z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_1", func {
			interpolated := this quaternion8 sphericalLinearInterpolation(this quaternion9, 0.5f)
			expect(interpolated w, is equal to(0.210042f) within(tolerance))
			expect(interpolated x, is equal to(0.0f) within(tolerance))
			expect(interpolated y, is equal to(0.700140f) within(tolerance))
			expect(interpolated z, is equal to(0.700140f) within(tolerance))
		})
		this add("sphericalLinearInterpolation_2", func {
			interpolated := this quaternion10 sphericalLinearInterpolation(this quaternion8, 0.0f)
			expect(interpolated w, is equal to(this quaternion10 w) within(tolerance))
			expect(interpolated x, is equal to(this quaternion10 x) within(tolerance))
			expect(interpolated y, is equal to(this quaternion10 y) within(tolerance))
			expect(interpolated z, is equal to(this quaternion10 z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_3", func {
			interpolated := this quaternion10 sphericalLinearInterpolation(this quaternion8, 1.0f)
			expect(interpolated w, is equal to(this quaternion8 w) within(tolerance))
			expect(interpolated x, is equal to(this quaternion8 x) within(tolerance))
			expect(interpolated y, is equal to(this quaternion8 y) within(tolerance))
			expect(interpolated z, is equal to(this quaternion8 z) within(tolerance))
		})
		this add("sphericalLinearInterpolation_4", func {
			interpolated := this quaternion10 sphericalLinearInterpolation(this quaternion8, 0.24f)
			expect(interpolated w, is equal to(0.13351797f) within(tolerance))
			expect(interpolated x, is equal to(0.38223242f) within(tolerance))
			expect(interpolated y, is equal to(0.71509135f) within(tolerance))
			expect(interpolated z, is equal to(0.57982165f) within(tolerance))
		})
		this add("sphericalLinearInterpolation_5", func {
			interpolated := this quaternion10 sphericalLinearInterpolation(this quaternion8, 0.9f)
			expect(interpolated w, is equal to(0.11061810f) within(tolerance))
			expect(interpolated x, is equal to(0.05838604f) within(tolerance))
			expect(interpolated y, is equal to(0.10923036f) within(tolerance))
			expect(interpolated z, is equal to(0.99080002f) within(tolerance))
		})
		this add("toString", func {
			string := this quaternion0 toString()
			expect(string, is equal to("Real: 33.000000 Imaginary: 10.000000 -12.000000 54.500000"))
			string free()
		})
		this add("weightedQuaternionMean_X", func {
			this quaternionList clear()
			this quaternionList add(Quaternion createRotationX(0.70f))
			this quaternionList add(Quaternion createRotationX(0.78f))
			this quaternionList add(Quaternion createRotationX(0.86f))
			weights := FloatVectorList getOnes(this quaternionList count)
			expect(Quaternion weightedMean(this quaternionList, weights) rotationX, is equal to(0.78f) within(0.001f))
			weights free()
		})
		this add("weightedQuaternionMean_Y", func {
			this quaternionList clear()
			this quaternionList add(Quaternion createRotationY(0.12f))
			this quaternionList add(Quaternion createRotationY(0.20f))
			this quaternionList add(Quaternion createRotationY(0.28f))
			weights := FloatVectorList getOnes(this quaternionList count)
			expect(Quaternion weightedMean(this quaternionList, weights) rotationY, is equal to(0.20f) within(0.001f))
			weights free()
		})
		this add("weightedQuaternionMean_Z", func {
			this quaternionList clear()
			this quaternionList add(Quaternion createRotationZ(-1.78f))
			this quaternionList add(Quaternion createRotationZ(-1.7f))
			this quaternionList add(Quaternion createRotationZ(-1.62f))
			weights := FloatVectorList getOnes(this quaternionList count)
			expect(Quaternion weightedMean(this quaternionList, weights) rotationZ, is equal to(-1.7f) within(0.001f))
			weights free()
		})
		this add("euler angles conversion", func {
			x := 0.1f
			y := 0.23f
			z := 0.04f
			quaternion := Quaternion createFromEulerAngles(x, y, z)
			expect(x, is equal to(quaternion rotationX) within(tolerance))
			expect(y, is equal to(quaternion rotationY) within(tolerance))
			expect(z, is equal to(quaternion rotationZ) within(tolerance))
		})
	}
	free: override func {
		this quaternionList free()
		super()
	}
}

QuaternionTest new() run() . free()
