/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use unit
use math

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
			(list, translation, translationX, translationY, translationZ, rotation, rotationX, rotationY, rotationZ, scaling) free()
		})
		this add("convolve", func {
			list := FloatEuclidTransformVectorList new()
			kernel := FloatVectorList gaussianKernel(3)
			translation1 := FloatVector3D new(19.11f, 20.31f, 103.64f)
			translation2 := FloatVector3D new(-12.2f, 63.31f, -3.64f)
			translation3 := FloatVector3D new(1.14f, 2.21f, -3.64f)
			filteredTranslation0 := (translation1 * kernel[0] + translation1 * kernel[1] + translation2 * kernel[2])
			filteredTranslation1 := (translation1 * kernel[0] + translation2 * kernel[1] + translation3 * kernel[2])
			filteredTranslation2 := (translation2 * kernel[0] + translation3 * kernel[1] + translation3 * kernel[2])
			rotation1 := FloatRotation3D createRotationZ(0.12f)
			rotation2 := FloatRotation3D createRotationX(0.31f)
			rotation3 := FloatRotation3D createRotationX(-0.63f)
			quaternionList := VectorList<Quaternion> new()
			quaternionList add(rotation1 _quaternion)
			quaternionList add(rotation1 _quaternion)
			quaternionList add(rotation2 _quaternion)
			filteredRotation0 := FloatRotation3D new(Quaternion weightedMean(quaternionList, kernel))
			quaternionList[0] = rotation1 _quaternion
			quaternionList[1] = rotation2 _quaternion
			quaternionList[2] = rotation3 _quaternion
			filteredRotation1 := FloatRotation3D new(Quaternion weightedMean(quaternionList, kernel))
			quaternionList[0] = rotation2 _quaternion
			quaternionList[1] = rotation3 _quaternion
			quaternionList[2] = rotation3 _quaternion
			filteredRotation2 := FloatRotation3D new(Quaternion weightedMean(quaternionList, kernel))
			scaling1 := 0.81f
			scaling2 := 0.43f
			scaling3 := 1.7f
			filteredScaling0 := (scaling1 * kernel[0] + scaling1 * kernel[1] + scaling2 * kernel[2])
			filteredScaling1 := (scaling1 * kernel[0] + scaling2 * kernel[1] + scaling3 * kernel[2])
			filteredScaling2 := (scaling2 * kernel[0] + scaling3 * kernel[1] + scaling3 * kernel[2])
			list add(FloatEuclidTransform new(translation1, rotation1, scaling1))
			list add(FloatEuclidTransform new(translation2, rotation2, scaling2))
			list add(FloatEuclidTransform new(translation3, rotation3, scaling3))
			filteredList := list convolve(kernel)
			expect(filteredList[0] translation == filteredTranslation0)
			expect(filteredList[1] translation == filteredTranslation1)
			expect(filteredList[2] translation == filteredTranslation2)
			expect(filteredList[0] rotation == filteredRotation0)
			expect(filteredList[1] rotation == filteredRotation1)
			expect(filteredList[2] rotation == filteredRotation2)
			expect(filteredList[0] scaling == filteredScaling0)
			expect(filteredList[1] scaling == filteredScaling1)
			expect(filteredList[2] scaling == filteredScaling2)
			(list, quaternionList, filteredList, kernel) free()
		})
	}
}

FloatEuclidTransformVectorListTest new() run() . free()
