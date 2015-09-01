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
import FloatComplexVectorList

FloatVectorList: class extends VectorList<Float> {
	init: func ~default {
		this super()
	}
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Float>) {
		this super(other _vector)
		this _count = other count
	}
	toVectorList: func -> VectorList<Float> {
		result := VectorList<Float> new()
		result _vector = this _vector
		result _count = this count
		result
	}
	sum: Float {
		get {
			result := 0.0f
			for (i in 0 .. this count)
				result += this[i]
			result
		}
	}
	maxValue: Float {
		get {
			result := Float negativeInfinity
			for (i in 0 .. this count)
				if (result < this[i])
					result = this[i]
			result
		}
	}
	minValue: Float {
		get {
			result := Float positiveInfinity
			for (i in 0 .. this count)
				if (result > this[i])
					result = this[i]
			result
		}
	}
	mean ::= this sum / this count
	variance: Float {
		get {
			squaredSum := 0.0f
			meanValue := this mean
			for (i in 0 .. this count)
				squaredSum += pow((this[i] - meanValue), 2.0f)
			squaredSum / this count
		}
	}
	standardDeviation ::= this variance sqrt()
	sort: func {
		This _quicksort(this _vector _backend as Float*, 0, this count - 1)
	}
	accumulate: func -> This {
		result := This new(this _count)
		sum := 0.0f
		for (i in 0 .. this _count) {
			sum += this[i]
			result add(sum)
		}
		result
	}
	absolute: func -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i] abs())
		result
	}
	copy: func -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i])
		result
	}
	operator + (other: This) -> This {
		result := This new()
		minimumCount := this count < other count ? this count : other count
		for (i in 0 .. minimumCount)
			result add(this[i] + other[i])
		result
	}
	addInto: func (other: This) {
		minimumCount := Int minimum(this count, other count)
		for (i in 0 .. minimumCount)
			this[i] = this[i] + other[i]
	}
	operator - (other: This) -> This {
		result := This new()
		minimumCount := this count < other count ? this count : other count
		for (i in 0 .. minimumCount)
			result add(this[i] - other[i])
		result
	}
	operator * (value: Float) -> This {
		result := This new()
		for (i in 0 .. this _count)
			result add(this[i] * value)
		result
	}
	operator / (value: Float) -> This {
		this * (1.0f / value)
	}
	operator + (value: Float) -> This {
		result := This new()
		for (i in 0 .. this _count)
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
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	divideByMaxValue: func -> This {
		max := this maxValue
		max != 0 ? (this / max) : this copy()
	}
	getOnes: static func (count: Float) -> This {
		result := This new(count)
		for (i in 0 .. count)
			result add(1.0f)
		result
	}
	getZeros: static func (count: Float) -> This {
		result := This new()
		for (i in 0 .. count)
			result add(0.0f)
		result
	}
	toFloatComplexVectorList: func -> FloatComplexVectorList {
		result := FloatComplexVectorList new()
		for (i in 0 .. this _count)
			result add(FloatComplex new(this[i], 0))
		result
	}
	convolve: func (kernel: This) -> This {
		result := This new(this count)
		for (i in 0 .. this count)
			result add(convolveAt(i, kernel))
		result
	}
	convolveAt: func (index: Int, kernel: This) -> Float {
		halfSize := round((kernel count - 1) / 2) as Int
		result := 0.0f
		for (kernelIndex in -halfSize .. halfSize + 1)
			result = result + this[(index + kernelIndex) clamp(0, this count - 1)] * kernel[halfSize + kernelIndex]
		result
	}
	gaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This gaussianKernel(size, size as Float / 3.0f)
	}
	gaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This new(size)
		factor := 1.0f / (sqrt(2.0f * Float pi) * sigma)
		for (i in 0 .. size)
			result add(factor * pow(Float e, -0.5f * ((i - (size - 1.0f) / 2.0f) squared()) / (sigma squared())))
		sum := result sum
		for (i in 0 .. size)
			result[i] = result[i] / sum
		result
	}
	forwardGaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This forwardGaussianKernel(size, size as Float / 3.0f)
	}
	forwardGaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This gaussianKernel(size, sigma)
		for (i in 0 .. (size - 1) / 2)
			result[i] = 0.0f
		sum := result sum
		for (i in 0 .. size)
			result[i] = result[i] / sum
		result
	}
	backwardGaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This backwardGaussianKernel(size, size as Float / 3.0f)
	}
	backwardGaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This new(size)
		forwardGaussian := This forwardGaussianKernel(size, sigma)
		for (i in 0 .. size)
			result add(forwardGaussian[size - i - 1])
		forwardGaussian free()
		result
	}
	getWaveletTransform: func (levels: Int) -> VectorList<This> {
		result := VectorList<This> new(levels)
		previous := this
		for (level in 0 .. levels) {
			size := 1 + pow(2, level + 1)
			kernel := This gaussianKernel(size)
			filtered := this convolve(kernel)
			kernel free()
			result add(previous - filtered)
			if (level > 0)
				previous free()
			previous = filtered
		}
		previous free()
		result
	}
	median: func -> Float {
		result: Float
		tempVector := this copy()
		tempVector sort()
		if (Int odd(this count))
			result = tempVector[this count / 2]
		else
			result = (tempVector[this count / 2 - 1] + tempVector[this count / 2]) / 2
		tempVector free()
		result
	}
	/* calculate median without copying and sorting the vector
			WARNING: this function can partially rearange the elements in vector
	*/
	fastMedian: func (start := 0, end := -1) -> Float {
		/*workaround for the compiler bug
		non-constant default function value is not calculated correctly
		*/
		if (end < 0)
			end = this count - 1
		count := end - start + 1
		result := This _nthElement(this _vector _backend as Float*, start, end, count / 2)
		if (Int even(count))
			result = (result + This _nthElement(this _vector _backend as Float*, start, end, count / 2 - 1)) / 2
		result
	}
	movingMedianFilter: func (windowSize: Int) -> This {
		result := This new(this count)
		windowBuffer := This new(windowSize)
		start := -((windowSize - 1) / 2)
		for (i in 0 .. this count) {
			range := ((start .. (start + windowSize - 1)) + i) clamp(0, this count-1)
			this getSliceInto(range, (windowBuffer as VectorList<Float>)&)
			result add((windowBuffer as This) fastMedian(0, range count - 1))
		}
		windowBuffer free()
		result
	}
	_swap: static func (array: Float*, i, j: Int) {
		t := array[i]
		array[i] = array[j]
		array[j] = t
	}
	/* partition the array so that all elements less than array[pivot] are moved before this element
		and all elements greater than array[pivot] are after it
		end should be the last valid array index in the range
	*/
	_partition: static func (array: Float*, start, end, pivot: Int) -> Int {
		pivotValue := array[pivot]
		This _swap(array, pivot, end)
		result := start
		for (i in start .. end)
			if (array[i] < pivotValue) {
				This _swap(array, result, i)
				++result
			}
		This _swap(array, result, end)
		result
	}
	/*
	pivot selection strategy which should result in best performance
	for quicksort and nthElement algorithms on partially sorted data
		end should be the last valid array index in the range
	*/
	_medianOfThree: static func (array: Float*, start, end: Int) -> Int {
		mid := (start + end) / 2
		if (array[start] > array[mid])
			This _swap(array, mid, start)
		if (array[mid] > array[end])
			This _swap(array, mid, end)
		if (array[start] > array[end])
			This _swap(array, start, end)
		mid
	}

	/* return n-th smallest element in the array[start:end] range
		end should be the last valid array index in the range
	*/
	_nthElement: static func (array: Float*, start, end, n: Int) -> Float {
		if (start == end)
			array[start]
		else {
			pivot := This _partition(array, start, end, This _medianOfThree(array, start, end))
			if (pivot == n)
				array[n]
			else if (n < pivot)
				_nthElement(array, start, pivot - 1, n)
			else
				_nthElement(array, pivot + 1, end, n)
		}
	}

	/* sort the input array in the range [start,end]
		end should be the last valid array index in the range
	*/
	_quicksort: static func (array: Float*, start, end: Int) {
		if (end == start + 1 && array[start] > array[end])
			This _swap(array, start, end)
		else if (start < end) {
			pivot := This _partition(array, start, end, This _medianOfThree(array, start, end))
			if (pivot > start)
				This _quicksort(array, start, pivot - 1)
			if (pivot < end)
				This _quicksort(array, pivot + 1, end)
		}
	}
}
