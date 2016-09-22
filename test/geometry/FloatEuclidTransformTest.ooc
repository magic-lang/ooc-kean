/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use math
use geometry
use unit

FloatEuclidTransformTest: class extends Fixture {
	init: func {
		tolerance := 1.0e-5f
		super("FloatEuclidTransform")
		this add("fixture", func {
			expect(FloatEuclidTransform new(FloatVector3D new(0, 0, 0), FloatRotation3D identity), is equal to(FloatEuclidTransform new(FloatVector3D new(0, 0, 0), FloatRotation3D identity)))
		})
		this add("convolveCenter translations 1", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			kernel := FloatVectorList new(5)
			for (i in 0 .. 5) {
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(i, i, i), FloatRotation3D identity))
				kernel add(0.2f)
			}
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)

			expect(result translation x, is equal to (euclidTransforms[2] translation x) within(tolerance))
			expect(result translation y, is equal to (euclidTransforms[2] translation y) within(tolerance))
			expect(result translation z, is equal to (euclidTransforms[2] translation z) within(tolerance))
			expect(result scaling, is equal to (euclidTransforms[2] scaling) within(tolerance))

			(kernel, euclidTransforms) free()
		})
		this add("convolveCenter translations 2", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			kernel := FloatVectorList gaussianKernel(5)
			for (i in 0 .. 5)
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(i, i, i), FloatRotation3D identity))
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)

			expectedResult := 0.0f
			for (i in 0 .. euclidTransforms count)
				expectedResult += kernel[i] * euclidTransforms[i] translation x

			expect(result translation x, is equal to (expectedResult) within(tolerance))
			expect(result translation y, is equal to (expectedResult) within(tolerance))
			expect(result translation z, is equal to (expectedResult) within(tolerance))
			expect(result scaling, is equal to (expectedResult - 1.0f) within(tolerance))

			(kernel, euclidTransforms) free()
		})
		this add("convolveCenter rotations", func {
			euclidTransforms := VectorList<FloatEuclidTransform> new(5)
			quaternions := VectorList<Quaternion> new(5)
			kernel := FloatVectorList gaussianKernel(5)
			for (i in 0 .. 5) {
				rotation := FloatRotation3D createRotationZ(i)
				quaternions add(rotation _quaternion)
				euclidTransforms add(FloatEuclidTransform new(FloatVector3D new(), rotation))
			}
			result := FloatEuclidTransform convolveCenter(euclidTransforms, kernel)
			expectedRotation := Quaternion weightedMean(quaternions, kernel)

			expect(result rotation _quaternion distance(expectedRotation), is equal to (0.0f) within(tolerance))

			(kernel, quaternions, euclidTransforms) free()
		})
		this add("inverse", func {
			transform := FloatEuclidTransform new(FloatVector3D new(), FloatRotation3D createRotationZ(3))
			inverse := transform inverse
			first := transform * inverse
			second := inverse * transform
			expect(first == second, is true)
			expect(first scaling as Float, is equal to(1.f) within(tolerance))

			(translation, quaternion) := (first translation as FloatVector3D, first rotation _quaternion as Quaternion)
			expect(translation norm, is equal to(0.f))
			expect(quaternion isIdentity, is true)
		})
		this add("mix", func {
			transform1 := FloatEuclidTransform new()
			transform2 := FloatEuclidTransform new(FloatVector3D new(1.f, 2.f, 3.f), FloatRotation3D createFromEulerAngles(0.1f, 0.2f, 0.3f), 0.95f)
			expect(transform1 mix(transform2, 0.f), is equal to(transform1))
			expect(transform1 mix(transform2, 1.f), is equal to(transform2))
			mixedTransform := transform1 mix(transform2, 0.5f)
			expect(mixedTransform translation, is equal to(FloatVector3D new(0.5f, 1.f, 1.5f)))
			expect(mixedTransform rotation, is equal to(FloatRotation3D new(Quaternion new(0.9958282709f, 0.0172071829f, 0.0532323383f, 0.0720868334f))))
			expect(mixedTransform scaling, is equal to(0.975f))
		})
	}
}

FloatEuclidTransformTest new() run() . free()
