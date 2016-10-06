/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use math
import FloatVector3D
import FloatRotation3D
import FloatTransform2D
import FloatTransform3D
import Quaternion

FloatEuclidTransform: cover {
	rotation: FloatRotation3D
	translation: FloatVector3D
	scaling: Float

	inverse ::= This new(-this translation, this rotation inverse, 1.0f / this scaling)
	transform ::= FloatTransform3D createScaling(this scaling, this scaling, 1.0f) * FloatTransform3D createTranslation(this translation) * this rotation transform

	init: func@ ~default (scale := 1.0f) { this init(FloatVector3D new(), FloatRotation3D identity, scale) }
	init: func@ ~translationAndRotation (translation: FloatVector3D, rotation: FloatRotation3D) { this init(translation, rotation, 1.0f) }
	init: func@ ~full (=translation, =rotation, =scaling)
	init: func@ ~fromTransform (transform: FloatTransform2D) {
		rotationZ := atan(- transform d / transform a)
		scaling := ((transform a * transform a + transform b * transform b) sqrt() + (transform d * transform d + transform e * transform e) sqrt()) / 2.0f
		this init(FloatVector3D new(transform g, transform h, 0.0f), FloatRotation3D createRotationZ(rotationZ), scaling)
	}
	toString: func (decimals := 6) -> String {
		"Translation: " << this translation toString(decimals) >> " Rotation: " & this rotation toString(decimals) >> " Scaling: " & this scaling toString(decimals)
	}

	operator * (other: This) -> This { This new(this translation + other translation, this rotation * other rotation, this scaling * other scaling) }
	operator == (other: This) -> Bool {
		this translation == other translation &&
		this rotation == other rotation &&
		this scaling equals(other scaling)
	}

	convolveCenter: static func (euclidTransforms: VectorList<This>, kernel: FloatVectorList) -> This {
		result := This new()
		if (euclidTransforms count > 0) {
			result scaling = 0.0f
			quaternions := VectorList<Quaternion> new(euclidTransforms count)
			for (i in 0 .. euclidTransforms count) {
				euclidTransform := euclidTransforms[i]
				weight := kernel[i]
				result translation = result translation + euclidTransform translation * weight
				result scaling = result scaling + euclidTransform scaling * weight
				rotation := euclidTransform rotation
				quaternions add(rotation _quaternion)
			}
			result rotation = FloatRotation3D new(Quaternion weightedMean(quaternions, kernel))
			quaternions free()
		}
		result
	}
	mix: func (other: This, factor: Float) -> This {
		This new(
			FloatVector3D mix(this translation, other translation, factor),
			FloatRotation3D new(this rotation _quaternion sphericalLinearInterpolation(other rotation _quaternion, factor)),
			Float mix(this scaling, other scaling, factor))
	}
}

extend Cell<FloatEuclidTransform> {
	toString: func ~floateuclidtransform -> String { (this val as FloatEuclidTransform) toString() }
}
