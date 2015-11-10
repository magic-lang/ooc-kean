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
use ooc-collections
import FloatPoint2D
import FloatVectorList

FloatPoint2DVectorList: class extends VectorList<FloatPoint2D> {
	init: func ~default {
		this super()
	}
	init: func ~fromVectorList (other: VectorList<FloatPoint2D>) {
		this super(other _vector)
		this _count = other count
	}
	toVectorList: func -> VectorList<FloatPoint2D> {
		result := VectorList<FloatPoint2D> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	sum: func -> FloatPoint2D {
		result := FloatPoint2D new()
		for (i in 0 .. this _count)
			result = result + this[i]
		result
	}
	mean: func -> FloatPoint2D {
		this sum() / this _count
	}
	getX: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			currentPoint := this[i]
			result add(currentPoint x)
		}
		result
	}
	getY: func -> FloatVectorList {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			currentPoint := this[i]
			result add(currentPoint y)
		}
		result
	}
	medianPosition: func -> FloatPoint2D {
		result := FloatPoint2D new()
		sortedX := this getX()
		sortedX sort()
		sortedY := this getY()
		sortedY sort()
		result x = sortedX[sortedX count / 2]
		result y = sortedY[sortedY count / 2]
		sortedX free()
		sortedY free()
		result
	}
	getMean: func (indices: VectorList<Int>) -> FloatPoint2D {
		result := FloatPoint2D new()
		indicesCount := indices count
		if (indicesCount > 0) {
			buffer := this pointer as FloatPoint2D*
			indicesBuffer := indices pointer as Int*
			for (i in 0 .. indicesCount) {
				index := indicesBuffer[i]
				element := buffer[index]
				result x = result x + element x
				result y = result y + element y
			}
			result x = result x / indicesCount
			result y = result y / indicesCount
		}
		result
	}
	operator + (value: FloatPoint2D) -> This {
		result := This new()
		for (i in 0 .. this _count)
			result add(this[i] + value)
		result
	}
	operator - (value: FloatPoint2D) -> This {
		this + (-value)
	}
	operator [] (index: Int) -> FloatPoint2D {
		this _vector[index] as FloatPoint2D
	}
	operator []= (index: Int, item: FloatPoint2D) {
		this _vector[index] = item
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
}
