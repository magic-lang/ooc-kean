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
import IntExtension
import FloatComplex
import FloatComplexVectorList
import FloatExtension

FloatVectorList: class extends VectorList<Float> {
	init: func ~default {
		this super()
	}
	init: func ~heap (capacity: Int){
		super(capacity)
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
	maxValue: Float {
		get {
			result := Float negativeInfinity
			for (i in 0..this count)
				if (result < this[i])
					result = this[i]
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
	copy: func -> This {
		result := This new(this _count)
		for (i in 0..this _count)
			result add(this[i])
		result
	}
	operator + (other: This) -> This {
		result := This new()
		minimumCount := this count < other count ? this count : other count
		for (i in 0..minimumCount)
			result add(this[i] + other[i])
		result
	}
	addInto: func (other: This) {
		minimumCount := Int minimum(this count, other count)
		for (i in 0..minimumCount)
			this[i] = this[i] + other[i]
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
	operator [] <T> (index: Int) -> T {
		this as VectorList<Float> _vector[index]
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
	toFloatComplexVectorList: func -> FloatComplexVectorList {
		result := FloatComplexVectorList new()
		for (i in 0..this _count)
			result add(FloatComplex new(this[i], 0))
		result
	}
	convolve: func (kernel: This) -> This {
		result := This new(this count)
		for (i in 0..this count)
			result add(convolveAt(i, kernel))
		result
	}
	convolveAt: func (index: Int, kernel: This) -> Float {
		halfSize := round((kernel count - 1) / 2) as Int
		result := 0.0f
		for (kernelIndex in -halfSize..halfSize + 1)
			result = result + this[(index + kernelIndex) clamp(0, this count - 1)] * kernel[halfSize + kernelIndex]
		result
	}
	gaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This gaussianKernel(size, size as Float / 3.0f)
	}
	gaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This new(size)
		factor := 1.0f / (sqrt(2.0f * Float pi) * sigma)
		for (i in 0..size)
			result add(factor * pow(Float e, -0.5f * ((i - (size - 1.0f) / 2.0f) squared()) / (sigma squared())))
		sum := result sum
		for (i in 0..size)
			result[i] = result[i] / sum
		result
	}
	forwardGaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This forwardGaussianKernel(size, size as Float / 3.0f)
	}
	forwardGaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This gaussianKernel(size, sigma)
		for (i in 0..(size - 1) / 2)
			result[i] = 0.0f
		sum := result sum
		for (i in 0..size)
			result[i] = result[i] / sum
		result
	}
	backwardGaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This backwardGaussianKernel(size, size as Float / 3.0f)
	}
	backwardGaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This new(size)
		forwardGaussian := This forwardGaussianKernel(size, sigma)
		for (i in 0..size)
			result add(forwardGaussian[size - i - 1])
		forwardGaussian free()
		result
	}
}
