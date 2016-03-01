/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use draw
use geometry

DrawStateTest: class extends Fixture {
	compareTransform: static func (resultTransform, correctTransform: FloatTransform3D, precision: Float) {
		expect(resultTransform a, is equal to(correctTransform a) within(precision))
		expect(resultTransform b, is equal to(correctTransform b) within(precision))
		expect(resultTransform c, is equal to(correctTransform c) within(precision))
		expect(resultTransform d, is equal to(correctTransform d) within(precision))
		expect(resultTransform e, is equal to(correctTransform e) within(precision))
		expect(resultTransform f, is equal to(correctTransform f) within(precision))
		expect(resultTransform g, is equal to(correctTransform g) within(precision))
		expect(resultTransform h, is equal to(correctTransform h) within(precision))
		expect(resultTransform i, is equal to(correctTransform i) within(precision))
		expect(resultTransform j, is equal to(correctTransform j) within(precision))
		expect(resultTransform k, is equal to(correctTransform k) within(precision))
		expect(resultTransform l, is equal to(correctTransform l) within(precision))
	}
	init: func {
		super("DrawState")
		this add("uniform scaling does not affect rotation", func {
			small := FloatVector2D new(150, 100)
			large := FloatVector2D new(300, 200)
			rotateX45 := FloatTransform3D createRotationX(45.0f toRadians())
			rotateX90 := FloatTransform3D createRotationX(90.0f toRadians())
			rotateY90 := FloatTransform3D createRotationY(90.0f toRadians())
			rotateZ90 := FloatTransform3D createRotationZ(90.0f toRadians())
			This compareTransform(rotateX45 referenceToNormalized(small) normalizedToReference(large), rotateX45, 0.001f)
			This compareTransform(rotateX90 referenceToNormalized(small) normalizedToReference(large), rotateX90, 0.001f)
			This compareTransform(rotateX90 referenceToNormalized(large) normalizedToReference(small), rotateX90, 0.001f)
			This compareTransform(rotateY90 referenceToNormalized(small) normalizedToReference(large), rotateY90, 0.001f)
			This compareTransform(rotateY90 referenceToNormalized(large) normalizedToReference(small), rotateY90, 0.001f)
			This compareTransform(rotateZ90 referenceToNormalized(small) normalizedToReference(large), rotateZ90, 0.001f)
			This compareTransform(rotateZ90 referenceToNormalized(large) normalizedToReference(small), rotateZ90, 0.001f)
		})
		this add("transform", func {
			imageSize := FloatVector2D new(1920, 1080)
			referenceTransform := FloatTransform3D createTranslation(300.0f, 200.0f, 100.0f) scale(2.0f, 3.0f, 4.0f) rotateX(4.2f) rotateY(-2.6f) rotateZ(1.5f)
			state := DrawState new() setTransformReference(referenceTransform, imageSize)
			outputTransform := state getTransformNormalized() normalizedToReference(imageSize)
			This compareTransform(outputTransform, referenceTransform, 0.0001f)
		})
		this add("syntax", func {
			opacityA := 0.3f
			opacityB := 0.7f
			viewportA := IntBox2D new(2, 3, 15, 10)
			viewportC := IntBox2D new(7, 4, 23, 27)
			stateA := DrawState new() setOpacity(opacityA) setViewport(viewportA)
			stateB := stateA setOpacity(opacityB)
			stateC := stateA setViewport(viewportC)
			expect(stateA opacity, is equal to(opacityA) within(0.0001f))
			expect(stateB opacity, is equal to(opacityB) within(0.0001f))
			expect(stateA viewport == viewportA)
			expect(stateB viewport == viewportA)
			expect(stateC viewport == viewportC)
		})
	}
}

DrawStateTest new() run() . free()
