/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit

FloatEuclidTransformVectorListTest: class extends Fixture {
	init: func {
		super("FloatEuclidTransformVectorList")
		tolerance := 0.0001f
		this add("get and set", func {
			list := FloatEuclidTransformVectorList new()
			euclidTransform1 := FloatEuclidTransform new(FloatVector3D new(1.0f, 2.0f, 3.0f), FloatRotation3D createRotationX(1.0f))
			euclidTransform2 := FloatEuclidTransform new(FloatVector3D new(5.0f, 6.0f, 7.0f), FloatRotation3D createRotationX(1.0f))
			list add(euclidTransform1)
			list add(euclidTransform2)
			expect(list[0] translation x, is equal to(euclidTransform1 translation x) within(tolerance))
			expect(list[1] translation x, is equal to(euclidTransform2 translation x) within(tolerance))
			expect(list[0] translation y, is equal to(euclidTransform1 translation y) within(tolerance))
			expect(list[1] translation y, is equal to(euclidTransform2 translation y) within(tolerance))
			expect(list[0] translation z, is equal to(euclidTransform1 translation z) within(tolerance))
			expect(list[1] translation z, is equal to(euclidTransform2 translation z) within(tolerance))
			expect(list[0] rotation angle(euclidTransform1 rotation), is equal to(0.0f) within(tolerance))
			expect(list[1] rotation angle(euclidTransform2 rotation), is equal to(0.0f) within(tolerance))
			expect(list[0] scaling, is equal to(euclidTransform1 scaling) within(tolerance))
			expect(list[1] scaling, is equal to(euclidTransform2 scaling) within(tolerance))
			list free()
		})
		this add("get lists", func {
			list := FloatEuclidTransformVectorList new()
			translation1 := FloatVector3D new(1.11f, 2.31f, 3.64f)
			translation2 := FloatVector3D new(2.85f, 3.18f, 4.26f)
			rotation1 := FloatRotation3D new(Quaternion new(1.21f, 2.31f, 3.14f, 4.23f))
			rotation2 := FloatRotation3D new(Quaternion new(2.51f, 3.12f, 4.41f, 5.42f))
			scaling1 := 5.72f
			scaling2 := 6.79f
			list add(FloatEuclidTransform new(translation1, rotation1, scaling1))
			list add(FloatEuclidTransform new(translation2, rotation2, scaling2))
			translation := list getTranslation()
			translationX := list getTranslationX()
			translationY := list getTranslationY()
			translationZ := list getTranslationZ()
			rotation := list getRotation()
			rotationX := list getRotationX()
			rotationY := list getRotationY()
			rotationZ := list getRotationZ()
			scaling := list getScaling()
			expect(translation[0] x, is equal to(translation1 x) within(tolerance))
			expect(translation[1] x, is equal to(translation2 x) within(tolerance))
			expect(translation[0] y, is equal to(translation1 y) within(tolerance))
			expect(translation[1] y, is equal to(translation2 y) within(tolerance))
			expect(translation[0] z, is equal to(translation1 z) within(tolerance))
			expect(translation[1] z, is equal to(translation2 z) within(tolerance))
			expect(translationX[0], is equal to(translation1 x) within(tolerance))
			expect(translationX[1], is equal to(translation2 x) within(tolerance))
			expect(translationY[0], is equal to(translation1 y) within(tolerance))
			expect(translationY[1], is equal to(translation2 y) within(tolerance))
			expect(translationZ[0], is equal to(translation1 z) within(tolerance))
			expect(translationZ[1], is equal to(translation2 z) within(tolerance))
			expect(rotation[0] angle(rotation1), is equal to(0.0f) within(tolerance))
			expect(rotation[1] angle(rotation2), is equal to(0.0f) within(tolerance))
			expect(rotationX[0], is equal to(rotation1 x) within(tolerance))
			expect(rotationX[1], is equal to(rotation2 x) within(tolerance))
			expect(rotationY[0], is equal to(rotation1 y) within(tolerance))
			expect(rotationY[1], is equal to(rotation2 y) within(tolerance))
			expect(rotationZ[0], is equal to(rotation1 z) within(tolerance))
			expect(rotationZ[1], is equal to(rotation2 z) within(tolerance))
			expect(scaling[0], is equal to(scaling1) within(tolerance))
			expect(scaling[1], is equal to(scaling2) within(tolerance))
			list free()
			translation free()
			translationX free()
			translationY free()
			translationZ free()
			rotation free()
			rotationX free()
			rotationY free()
			rotationZ free()
			scaling free()
		})
		this add("toText", func {
			list := FloatEuclidTransformVectorList new()
			translation := FloatVector3D new(1.11f, 2.31f, 3.64f)
			rotation := FloatRotation3D new(Quaternion new(1.21f, 2.31f, 3.14f, 4.23f))
			scaling := 5.72f
			list add(FloatEuclidTransform new(translation, rotation, scaling))
			text := list toText() take()
			expect(text, is equal to(t"Translation: 1.11, 2.31, 3.64 Rotation: Real: 1.21 Imaginary: 2.31 3.14 4.23 Scaling: 5.72"))
			text free()
			list free()
		})
	}
}

FloatEuclidTransformVectorListTest new() run() . free()
