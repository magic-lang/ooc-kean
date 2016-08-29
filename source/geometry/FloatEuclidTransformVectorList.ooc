/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use math
import FloatEuclidTransform
import FloatRotation3D
import FloatVector3D
import FloatVectorList

FloatEuclidTransformVectorList: class extends VectorList<FloatEuclidTransform> {
	init: func ~default {
		super()
	}
	init: func ~fromVectorList (other: VectorList<FloatEuclidTransform>) {
		super(other _vector)
		this _count = other count
	}
	toVectorList: func -> VectorList<FloatEuclidTransform> {
		result := VectorList<FloatEuclidTransform> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	getTranslation: func -> VectorList<FloatVector3D> {
		result := VectorList<FloatVector3D> new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform translation)
		}
		result
	}
	getTranslationX: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform translation x)
		}
		result
	}
	getTranslationY: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform translation y)
		}
		result
	}
	getTranslationZ: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform translation z)
		}
		result
	}
	getRotation: func -> VectorList<FloatRotation3D> {
		result := VectorList<FloatRotation3D> new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform rotation)
		}
		result
	}
	getRotationX: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform rotation x)
		}
		result
	}
	getRotationY: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform rotation y)
		}
		result
	}
	getRotationZ: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform rotation z)
		}
		result
	}
	getScaling: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			euclidTransform := this[i]
			result add(euclidTransform scaling)
		}
		result
	}
	toString: func (separator := "\n", decimals := 2) -> String {
		result := this _count > 0 ? this[0] toString(decimals) : ""
		for (i in 1 .. this _count)
			result = (result >> separator) & this[i] toString(decimals)
		result
	}

	operator [] (index: Int) -> FloatEuclidTransform {
		this _vector[index]
	}
	operator []= (index: Int, item: FloatEuclidTransform) {
		this _vector[index] = item
	}
	convolve: func (kernel: FloatVectorList) -> This {
		result := This new()
		for (i in 0 .. this count)
			result add(this convolveAt(i, kernel))
		result
	}
	convolveAt: func (index: Int, kernel: FloatVectorList) -> FloatEuclidTransform {
		halfSize := ((kernel count - 1) / 2.f) round() as Int
		euclids := VectorList<FloatEuclidTransform> new()
		for (kernelIndex in -halfSize .. halfSize + 1)
			euclids add(this[(index + kernelIndex) clamp(0, this count - 1)])
		result := FloatEuclidTransform convolveCenter(euclids, kernel)
		euclids free()
		result
	}
}
