/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use base
use collections
use ooc-math
import FloatEuclidTransform
import FloatRotation3D
import FloatVector3D

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
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	toText: func -> Text {
		result: Text
		textBuilder := TextBuilder new()
		for (i in 0 .. this _count)
			textBuilder append(this[i] toText())
		result = textBuilder join(t"\n")
		textBuilder free()
		result
	}

	operator [] (index: Int) -> FloatEuclidTransform {
		this _vector[index]
	}
	operator []= (index: Int, item: FloatEuclidTransform) {
		this _vector[index] = item
	}
}
