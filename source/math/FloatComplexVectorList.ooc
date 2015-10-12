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
	init: func ~withValue (capacity: Int, value: FloatComplex) -> This {
		super(capacity)
		for (i in 0 .. capacity)
			this add(value)
		this
	}
	toVectorList: func -> VectorList<FloatComplex> {
		result := VectorList<FloatComplex> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	sum: FloatComplex {
		get {
			result := FloatComplex new()
			for (i in 0 .. this _count)
				result = result + this[i]
			result
		}
	}
	mean ::= this sum / this _count
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
		result := This new(input count)
		result _count = input count
		for (i in 0 .. input count)
			for (j in 0 .. input count)
				result[i] = result[i] + input[j] * FloatComplex rootOfUnity(input count, -i * j)
		result
	}
	inverseDiscreteFourierTransform: static func (input: This) -> This {
		conjugates := This new(input count)
		for (i in 0 .. input count)
			conjugates add(input[i] conjugate)
		result := This discreteFourierTransform(conjugates)
		conjugates free()
		for (i in 0 .. (result count))
			result[i] = (result[i] conjugate) / (input count)
		result
	}
	fastFourierTransform: static func (input: This) -> This {
		result := This new(input count)
		result _count = input count
		if (input count > 0) {
			buffer := This createFFTBuffer(input count)
			This fastFourierTransformInto(input, result, buffer)
			buffer free()
		}
		result
	}
	fastFourierTransformInPlace: static func (input: This) {
		if (input count > 0) {
			buffer := This createFFTBuffer(input count)
			This fastFourierTransformInto(input, input, buffer)
			buffer free()
		}
	}
	/* for input of size N, buffer size needs to be at least log2(N)*N*/
	fastFourierTransform: static func ~withBuffer (input, buffer: This) -> This {
		result := This new(input count)
		result _count = input count
		if (input count > 0)
			This fastFourierTransformInto(input, result, buffer)
		result
	}
	fastFourierTransformInPlace: static func ~withBuffer (input, buffer: This) {
		This fastFourierTransformInto(input, input, buffer)
	}
	fastFourierTransformInto: static func (input, result: This) {
		if (input count > 0) {
			buffer := This createFFTBuffer(input count)
			This fastFourierTransformInto(input, result, buffer)
			buffer free()
		}
	}
	fastFourierTransformInto: static func ~withBuffer (input, result, buffer: This) {
		This _fastFourierTransformHelper(input, 0, input count, buffer, 0, result, 0)
	}
	createFFTBuffer: static func (inputSize: Int) -> This {
		result := This new(This _fastFourierTransformBufferSize(inputSize))
		result _count = inputSize
		result
	}
	inverseFastFourierTransform: static func (input: This) -> This {
		conjugates := This new(input count)
		for (i in 0 .. input count)
			conjugates add(input[i] conjugate)
		result := This fastFourierTransform(conjugates)
		conjugates free()
		for (i in 0 .. result count)
			result[i] = (result[i] conjugate) / (input count)
		result
	}
	_fastFourierTransformBufferSize: static func (inputSize: Int) -> Int {
		logValue := inputSize as Float log2()
		(logValue + 1.0f) floor() * inputSize
	}
	_fastFourierTransformHelper: static func (input: This, start, count: Int, buffer: This, bufferOffset: Int, result: This, resultOffset: Int) {
		version (safe) {
			if (buffer count < This _fastFourierTransformBufferSize(count))
				raise("Buffer size too small in fastFourierTransform")
		}
		if (count == 1)
			result[resultOffset] = input[start]
		else {
			halfLength: Int = count / 2
			for (i in 0 .. halfLength) {
				buffer[bufferOffset + i] = input[start + 2 * i]
				buffer[bufferOffset + i + halfLength] = input[start + 2 * i + 1]
			}
			This _fastFourierTransformHelper(buffer, bufferOffset, halfLength, buffer, bufferOffset + count, result, resultOffset)
			This _fastFourierTransformHelper(buffer, bufferOffset + halfLength, halfLength, buffer, bufferOffset + count, result, resultOffset + halfLength)
			for (i in 0 .. halfLength) {
				root := FloatComplex rootOfUnity(count, -i)
				even := result[resultOffset + i]
				odd := result[resultOffset + i + halfLength]
				result[resultOffset + i] = even + root * odd
				result[resultOffset + i + halfLength] = even - root * odd
			}
		}
	}
}
