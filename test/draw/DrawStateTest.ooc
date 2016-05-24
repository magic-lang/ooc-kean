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
	compareTransform: static func (resultTransform, correctTransform: FloatTransform3D, tolerance: Float) {
		expect(resultTransform a, is equal to(correctTransform a) within(tolerance))
		expect(resultTransform b, is equal to(correctTransform b) within(tolerance))
		expect(resultTransform c, is equal to(correctTransform c) within(tolerance))
		expect(resultTransform d, is equal to(correctTransform d) within(tolerance))
		expect(resultTransform e, is equal to(correctTransform e) within(tolerance))
		expect(resultTransform f, is equal to(correctTransform f) within(tolerance))
		expect(resultTransform g, is equal to(correctTransform g) within(tolerance))
		expect(resultTransform h, is equal to(correctTransform h) within(tolerance))
		expect(resultTransform i, is equal to(correctTransform i) within(tolerance))
		expect(resultTransform j, is equal to(correctTransform j) within(tolerance))
		expect(resultTransform k, is equal to(correctTransform k) within(tolerance))
		expect(resultTransform l, is equal to(correctTransform l) within(tolerance))
	}
	init: func {
		super("DrawState")
		this add("uniform scaling does not affect rotation", func {
			rotateX45 := FloatTransform3D createRotationX(45.0f toRadians())
			rotateX90 := FloatTransform3D createRotationX(90.0f toRadians())
			rotateY90 := FloatTransform3D createRotationY(90.0f toRadians())
			rotateZ90 := FloatTransform3D createRotationZ(90.0f toRadians())
			This compareTransform(rotateX45 referenceToNormalized(FloatVector2D new(150, 100)) normalizedToReference(FloatVector2D new(300, 200)), rotateX45, 0.001f)
			This compareTransform(rotateX90 referenceToNormalized(FloatVector2D new(150, 100)) normalizedToReference(FloatVector2D new(300, 200)), rotateX90, 0.001f)
			This compareTransform(rotateX90 referenceToNormalized(FloatVector2D new(300, 200)) normalizedToReference(FloatVector2D new(150, 100)), rotateX90, 0.001f)
			This compareTransform(rotateY90 referenceToNormalized(FloatVector2D new(150, 100)) normalizedToReference(FloatVector2D new(300, 200)), rotateY90, 0.001f)
			This compareTransform(rotateY90 referenceToNormalized(FloatVector2D new(300, 200)) normalizedToReference(FloatVector2D new(150, 100)), rotateY90, 0.001f)
			This compareTransform(rotateZ90 referenceToNormalized(FloatVector2D new(150, 100)) normalizedToReference(FloatVector2D new(300, 200)), rotateZ90, 0.001f)
			This compareTransform(rotateZ90 referenceToNormalized(FloatVector2D new(300, 200)) normalizedToReference(FloatVector2D new(150, 100)), rotateZ90, 0.001f)
		})
		this add("transform", func {
			imageSize := FloatVector2D new(1920, 1080)
			referenceTransform := FloatTransform3D createTranslation(300.0f, 200.0f, 100.0f) scale(2.0f, 3.0f, 4.0f) rotateX(4.2f) rotateY(-2.6f) rotateZ(1.5f)
			state := DrawState new() setTransformReference(referenceTransform, imageSize)
			outputTransform := state getTransformNormalized() normalizedToReference(imageSize)
			This compareTransform(outputTransform, referenceTransform, 0.0001f)
		})
	}
}

DrawStateTest new() run() . free()
