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
import FloatVector

FloatPoint2DList: class extends VectorList<FloatPoint2D> {
	init: func ~default {
		this super()
	}
	init: func ~fromVectorList (other: VectorList<FloatPoint2D>) {
		this super(other _vector)
		this _count = other count
	}
	toVectorList: func() -> VectorList<FloatPoint2D> {
		result := VectorList<FloatPoint2D> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	sum: func -> FloatPoint2D {
		result := FloatPoint2D new()
		for (i in 0..this _count)
			result = result + this[i]
		result
	}
	mean: func -> FloatPoint2D {
		sum() / this _count
	}
	getX: func -> FloatVector {
		result := FloatVector new()
		for (i in 0..this _count) {
			currentPoint := this[i]
			result add(currentPoint x)
		}
		result
	}
	getY: func -> FloatVector {
		result := FloatVector new()
		for (i in 0..this _count) {
			currentPoint := this[i]
			result add(currentPoint y)
		}
		result
	}
	medianPosition: func -> FloatPoint2D {
		result := FloatPoint2D new()
		sortedX := getX()
		sortedX sort()
		sortedY := getY()
		sortedY sort()
		result x = sortedX[sortedX count / 2]
		result y = sortedY[sortedY count / 2]
		sortedX free()
		sortedY free()
		result
	}
	operator + (value: FloatPoint2D) -> This {
		result := This new()
		for (i in 0..this _count)
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
	toString: func() -> String {
		result := ""
		for (i in 0..this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
}
