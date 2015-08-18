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
import FloatComplex
use ooc-collections
import FloatVectorList
import math

FloatComplexVectorList: class extends VectorList<FloatComplex> {
	init: func ~default {
		super()
	}
	init: func ~capacity (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<FloatComplex>) {
		super(other _vector)
		this _count = other count
	}
	toVectorList: func -> VectorList<FloatComplex> {
		result := VectorList<FloatComplex> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	sum: func -> FloatComplex {
		result := FloatComplex new()
		for (i in 0 .. this _count)
			result = result + this[i]
		result
	}
	mean: func -> FloatComplex {
		sum() / this _count
	}
	copy: func -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i])
		result
	}
	real: FloatVectorList {
		get {
			result := FloatVectorList new()
			for (i in 0 .. this _count) {
				currentPoint := this[i]
				result add(currentPoint real)
			}
			result
		}
	}
	imaginary: FloatVectorList {
		get {
			result := FloatVectorList new()
			for (i in 0 .. this _count) {
				currentPoint := this[i]
				result add(currentPoint imaginary)
			}
			result
		}
	}
	addInto: func (other: This) {
		minimumCount := Int minimum(this count, other count)
		for (i in 0 .. minimumCount)
			this[i] = this[i] + other[i]
	}
	operator + (value: FloatComplex) -> This {
		result := This new()
		for (i in 0 .. this _count)
			result add(this[i] + value)
		result
	}
	operator - (value: FloatComplex) -> This {
		this + (-value)
	}
	operator [] <T> (index: Int) -> T {
		this as VectorList<FloatComplex> _vector[index]
	}
	operator []= (index: Int, item: FloatComplex) {
		this _vector[index] = item
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	discreteFourierTransform: static func (input: This) -> This {
		result := This createDefault(input count)
		for (i in 0 .. (input count))
			for (j in 0 .. (input count))
				result[i] = result[i] + input[j] * FloatComplex rootOfUnity(input count, -i * j)
		result
	}
	inverseDiscreteFourierTransform: static func (input: This) -> This {
		conjugates := This new()
		for (i in 0 .. (input count))
			conjugates add(input[i] conjugate)
		result := This discreteFourierTransform(conjugates)
		conjugates free()
		for (i in 0 .. (result count))
			result[i] = (result[i] conjugate) / (input count)
		result
	}
	fastFourierTransform: static func (input: This) -> This {
		result: This
		if (input count == 1)
			result = input
		else {
			result = createDefault(input count)
			halfLength: Int = input count / 2
			evenInput := This new()
			oddInput := This new()
			for (i in 0 .. halfLength) {
				evenInput add(input[2 * i])
				oddInput add(input[2 * i + 1])
			}
			evenOutput := This fastFourierTransform(evenInput)
			oddOutput := This fastFourierTransform(oddInput)
			for (i in 0 .. halfLength) {
				root := FloatComplex rootOfUnity(input count, -i)
				result[i] = evenOutput[i] + root * oddOutput[i]
				result[halfLength + i] = evenOutput[i] - root * oddOutput[i]
			}
			evenOutput free()
			oddOutput free()
		}
		result
	}
	inverseFastFourierTransform: static func (input: This) -> This {
		conjugates := This new()
		for (i in 0 .. (input count))
			conjugates add(input[i] conjugate)
		result := This fastFourierTransform(conjugates)
		conjugates free()
		for (i in 0 .. (result count))
			result[i] = (result[i] conjugate) / (input count)
		result
	}
	createDefault: static func (capacity: Int) -> This {
		result := This new(capacity)
		result _count = capacity
		result
	}
	createDefault: static func ~withValue (capacity: Int, value: FloatComplex) -> This {
		result := This new(capacity)
		for (i in 0 .. capacity)
				result add(value)
		result
	}
}
