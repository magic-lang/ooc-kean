/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit

FloatRotation3DTest: class extends Fixture {
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
	init: func {
		super("FloatRotation3D")
		tolerance := 0.0001f
		this add("fixture", func {
			expect(this quaternion0 + this quaternion1, is equal to(this quaternion2) within(tolerance))
		})
		this add("identity", func {
			rotation := FloatRotation3D identity
			expect(rotation inverse == rotation, is true)
		})
		this add("operators", func {
			rotation0 := FloatRotation3D new(this quaternion0)
			rotation1 := FloatRotation3D new(this quaternion1)
			rotation2 := FloatRotation3D new(this quaternion2)
			rotation3 := FloatRotation3D new(this quaternion3)
			rotation4 := FloatRotation3D new(this quaternion4)

			expect(rotation1 == rotation4)
			expect(rotation2 == rotation3, is false)
			expect(rotation3 != rotation4)
			expect(rotation1 != rotation4, is false)

			expect(rotation0 * rotation1 == rotation3)
		})
		this add("normalized", func {
			rotation := FloatRotation3D new(this quaternion0)
			normalized := (rotation normalized) _quaternion
			w := normalized w as Float
			x := normalized x as Float
			y := normalized y as Float
			z := normalized z as Float
			expect(w, is equal to(0.5030552f) within(tolerance))
			expect(x, is equal to(0.1524409f) within(tolerance))
			expect(y, is equal to(-0.1829291f) within(tolerance))
			expect(z, is equal to(0.8308033f) within(tolerance))
		})
		this add("sphericalLinearInterpolation", func {
			rotation8 := FloatRotation3D new(this quaternion8)
			rotation9 := FloatRotation3D new(this quaternion9)
			interpolated := rotation8 sphericalLinearInterpolation(rotation9, 0.5f)
			expect(interpolated _quaternion w, is equal to(0.210042f) within(tolerance))
			expect(interpolated _quaternion x, is equal to(0.0f) within(tolerance))
			expect(interpolated _quaternion y, is equal to(0.700140f) within(tolerance))
			expect(interpolated _quaternion z, is equal to(0.700140f) within(tolerance))
		})
		this add("angle", func {
			direction := FloatVector3D new(1.0f, 1.0f, 1.0f)
			quaternionA := Quaternion createFromAxisAngle(direction, 20.0f toRadians())
			quaternionB := Quaternion createFromAxisAngle(direction, 45.0f toRadians())
			rotationA := FloatRotation3D new(quaternionA)
			rotationB := FloatRotation3D new(quaternionB)
			angle := (rotationA angle(rotationB)) toDegrees()
			expect(angle, is equal to(25.0f) within(tolerance))
		})
		this add("euler angles conversion", func {
			x := 0.1f
			y := 0.23f
			z := 0.04f
			rotation := FloatRotation3D createFromEulerAngles(x, y, z)
			expect(x, is equal to(rotation x) within(tolerance))
			expect(y, is equal to(rotation y) within(tolerance))
			expect(z, is equal to(rotation z) within(tolerance))
		})
	}
}

FloatRotation3DTest new() run() . free()
