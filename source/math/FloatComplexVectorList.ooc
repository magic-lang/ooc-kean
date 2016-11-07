/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import FloatComplex
use base
use collections
import FloatVectorList

FloatComplexVectorList: class extends VectorList<FloatComplex> {
	mean ::= this sum / this _count
	sum: FloatComplex { get {
		result := FloatComplex new()
		for (i in 0 .. this _count)
			result = result + this[i]
		result
	}}
	real: FloatVectorList { get {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			currentPoint := this[i]
			result add(currentPoint real)
		}
		result
	}}
	imaginary: FloatVectorList { get {
		result := FloatVectorList new()
		for (i in 0 .. this _count) {
			currentPoint := this[i]
			result add(currentPoint imaginary)
		}
		result
	}}

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
	init: func ~withValue (capacity: Int, value: FloatComplex) {
		super(capacity)
		for (i in 0 .. capacity)
			this add(value)
	}
	toVectorList: func -> VectorList<FloatComplex> {
		result := VectorList<FloatComplex> new()
		result _vector = this _vector
		result _count = this _count
		result
	}
	copy: override func -> This {
		super() as This
	}
	addInto: func (other: This) {
		minimumCount := this count minimum(other count)
		thisPointer := (this pointer as FloatComplex*)
		otherPointer := (other pointer as FloatComplex*)
		for (i in 0 .. minimumCount) {
			thisPointer[i] real = thisPointer[i] real + otherPointer[i] real
			thisPointer[i] imaginary = thisPointer[i] imaginary + otherPointer[i] imaginary
		}
	}
	toString: func (separator := "\n", decimals := 2) -> String {
		result := this _count > 0 ? this[0] toString(decimals) : ""
		for (i in 1 .. this _count)
			result = (result >> separator) & this[i] toString(decimals)
		result
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

	getZeros: static func (count: Int) -> This {
		result := This new(count)
		result _count = count
		result
	}
	discreteFourierTransform: static func (input: This) -> This {
		result := This getZeros(input count)
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
		result := This getZeros(input count)
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
		result := This getZeros(input count)
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
		This getZeros(This _fastFourierTransformBufferSize(inputSize))
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
		version (safe)
			Debug error(buffer count < This _fastFourierTransformBufferSize(count), "Buffer size too small in fastFourierTransform")
		resultBuffer := result pointer as FloatComplex*
		inputBuffer := input pointer as FloatComplex*
		temporaryBuffer := buffer pointer as FloatComplex*
		if (count == 1)
			resultBuffer[resultOffset] = inputBuffer[start]
		else {
			halfLength: Int = count / 2
			for (i in 0 .. halfLength) {
				temporaryBuffer[bufferOffset + i] = inputBuffer[start + 2 * i]
				temporaryBuffer[bufferOffset + i + halfLength] = inputBuffer[start + 2 * i + 1]
			}
			This _fastFourierTransformHelper(buffer, bufferOffset, halfLength, buffer, bufferOffset + count, result, resultOffset)
			This _fastFourierTransformHelper(buffer, bufferOffset + halfLength, halfLength, buffer, bufferOffset + count, result, resultOffset + halfLength)
			for (i in 0 .. halfLength) {
				rootTimesOdd := FloatComplex rootOfUnity(count, -i) * resultBuffer[resultOffset + i + halfLength]
				resultBuffer[resultOffset + i + halfLength] real = resultBuffer[resultOffset + i] real - rootTimesOdd real
				resultBuffer[resultOffset + i + halfLength] imaginary = resultBuffer[resultOffset + i] imaginary - rootTimesOdd imaginary
				resultBuffer[resultOffset + i] real = resultBuffer[resultOffset + i] real + rootTimesOdd real
				resultBuffer[resultOffset + i] imaginary = resultBuffer[resultOffset + i] imaginary + rootTimesOdd imaginary
			}
		}
	}
}
