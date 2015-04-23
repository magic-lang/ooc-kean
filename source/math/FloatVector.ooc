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
import math
import FloatComplex
import FloatComplexList
FloatVector: class extends VectorList<Float> {
	init: func ~default {
		this super()
	}
	init: func ~fromVectorList (other: VectorList<Float>) {
		this super(other _vector)
		this _count = other count
	}
	toVectorList: func() -> VectorList<Float> {
		result := VectorList<Float> new()
		result _vector = this _vector
		result _count = this count
		result
	}
	sum: Float {
		get {
			result := 0.0f
			for (i in 0..this count)
				result += this[i]
			result
		}
	}
	mean ::= this sum / this count
	variance: Float {
		get {
			squaredSum := 0.0f
			for (i in 0..this count)
				squaredSum += pow((this[i] - this mean), 2.0f)
			squaredSum / this count
		}
	}
	standardDeviation ::= sqrt(this variance)
	sort: func {
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0..count - 1) {
				if (this[i] > this[i + 1]) {
					inOrder = false
					tmp := this[i]
					this[i] = this[i + 1]
					this[i + 1] = tmp
				}
			}
		}
	}
	operator + (other: This) -> This {
		result := This new()
		minimumCount := this count < other count ? this count : other count
		for (i in 0..minimumCount)
			result add(this[i] + other[i])
		result
	}
	operator - (other: This) -> This {
		result := This new()
		minimumCount := this count < other count ? this count : other count
		for (i in 0..minimumCount)
			result add(this[i] - other[i])
		result
	}
	operator * (value: Float) -> This {
		result := This new()
		for (i in 0..this _count)
			result add(this[i] * value)
		result
	}
	operator / (value: Float) -> This {
		this * (1.0f / value)
	}
	operator + (value: Float) -> This {
		result := This new()
		for (i in 0..this _count)
			result add(this[i] + value)
		result
	}
	operator - (value: Float) -> This {
		this + (-value)
	}
	operator [] (index: Int) -> Float {
		this _vector[index] as Float
	}
	operator []= (index: Int, item: Float) {
		this _vector[index] = item
	}
	toString: func() -> String {
		result := ""
		for (i in 0..this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	toFloatComplexList: func -> FloatComplexList {
		result := FloatComplexList new()
		for (i in 0..this _count)
			result add(FloatComplex new(this[i], 0))
		result
	}
}
