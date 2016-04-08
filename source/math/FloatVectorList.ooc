/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use base
import structs/Vector
import FloatComplex
import FloatComplexVectorList
import FloatMatrix

FloatVectorList: class extends VectorList<Float> {
	standardDeviation ::= this variance sqrt()
	mean ::= this sum / this count
	sum: Float { get {
		result := 0.0f
		for (i in 0 .. this count)
			result += this[i]
		result
	}}
	maxValue: Float { get {
		result := Float negativeInfinity
		for (i in 0 .. this count)
			if (result < this[i])
				result = this[i]
		result
	}}
	minValue: Float { get {
		result := Float positiveInfinity
		for (i in 0 .. this count)
			if (result > this[i])
				result = this[i]
		result
	}}
	variance: Float { get {
		squaredSum := 0.0f
		meanValue := this mean
		for (i in 0 .. this count)
			squaredSum += (this[i] - meanValue) pow(2.0f)
		squaredSum / this count
	}}

	init: func ~default {
		super()
	}
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Float>) {
		super(other _vector)
		this _count = other count
	}
	init: func ~withValue (capacity: Int, value: Float) {
		super(capacity)
		for (i in 0 .. capacity)
			this add(value)
	}
	toVectorList: func -> VectorList<Float> {
		result := VectorList<Float> new(this count)
		result _vector = this _vector
		result _count = this count
		result
	}
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
	reverse: func -> This {
		super() as This
	}
	addInto: func (other: This) {
		minimumCount := this count minimum(other count)
		for (i in 0 .. minimumCount)
			this[i] = this[i] + other[i]
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
	divideByMaxValue: func -> This {
		max := this maxValue
		max != 0 ? (this / max) : this copy()
	}
	sum: func ~range (range: Range) -> Float {
		this sum(range min, range max)
	}
	sum: func (start, end: Int) -> Float {
		version(safe)
			raise(start < 0 || start >= this count || end < 0 || end >= this count , "invalid range in FloatVectorList sum()")
		result := this[start]
		for (i in start + 1 .. end + 1)
			result += this[i]
		result
	}
	exp: func -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i] exp())
		result
	}
	toFloatComplexVectorList: func -> FloatComplexVectorList {
		result := FloatComplexVectorList new(this _count)
		for (i in 0 .. this _count)
			result add(FloatComplex new(this[i], 0))
		result
	}
	convolve: func (kernel: This) -> This {
		result := This new(this count)
		for (i in 0 .. this count)
			result add(this convolveAt(i, kernel))
		result
	}
	convolveAt: func (index: Int, kernel: This) -> Float {
		halfSize := ((kernel count - 1) / 2.f) round() as Int
		result := 0.0f
		for (kernelIndex in -halfSize .. halfSize + 1)
			result = result + this[(index + kernelIndex) clamp(0, this count - 1)] * kernel[halfSize + kernelIndex]
		result
	}
	getWaveletTransform: func (levels: Int) -> VectorList<This> {
		result := VectorList<This> new(levels)
		previous := this
		for (level in 0 .. levels) {
			size := 1 + (2 pow(level + 1))
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
		if (this count isOdd)
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
		if (count isEven)
			result = (result + This _nthElement(this _vector _backend as Float*, start, end, count / 2 - 1)) / 2
		result
	}
	movingMedianFilter: func (windowSize: Int) -> This {
		result := This new(this count)
		windowBuffer := This new(windowSize)
		start := -((windowSize - 1) / 2)
		for (i in 0 .. this count) {
			range := ((start .. (start + windowSize - 1)) + i) clamp(0, this count-1)
			this getSliceInto(range, (windowBuffer as VectorList<Float>))
			result add((windowBuffer as This) fastMedian(0, range count - 1))
		}
		windowBuffer free()
		result
	}
	clamp: func (floor, ceiling: Float) -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i] clamp(floor, ceiling))
		result
	}
	findIndexOfMaximum: func -> Int {
		index := 0
		thisPointer := (this pointer as Float*)
		for (i in 1 .. this count)
			if (thisPointer[index] < thisPointer[i])
				index = i
		index
	}
	calculateCorrelation: func (other: This, vectorLength: Int) -> Float {
		upperPart := 0.0f
		lowerPart1 := 0.0f
		lowerPart2 := 0.0f
		thisMean := this mean
		otherMean := other mean
		thisPointer := (this pointer as Float*)
		otherPointer := (other pointer as Float*)
		for (i in 0 .. vectorLength) {
			thisValue := thisPointer[i]
			otherValue := otherPointer[i]
			thisDiff := (thisValue - thisMean)
			otherDiff := (otherValue - otherMean)
			upperPart += thisDiff * otherDiff
			lowerPart1 += thisDiff * thisDiff
			lowerPart2 += otherDiff * otherDiff
		}
		upperPart / sqrt(lowerPart1 * lowerPart2)
	}
	shift: func (offset: Int, filledValue := 0.0f) -> This {
		result := This new(this count)
		thisPointer := (this pointer as Float*)
		for (i in 0 .. this count) {
			index := i + offset
			value := (index >= 0 && index < this count) ? thisPointer[index] : filledValue
			result add(value)
		}
		result
	}
	// offset < 0 means it shifts to left, offsets contains lags to crossCorrelation
	calculateCrossCorrelation: func (other: This, offsetRange: Range, calculateOffsets := true) -> (This, This) {
		crossCorrelation := This new(offsetRange count)
		offsets: This = calculateOffsets ? This new(offsetRange count) : null
		for (offset in offsetRange min .. offsetRange max + 1) {
			temporary := this shift(offset)
			crossCorrelation add(temporary calculateCorrelation(other, other count))
			if (calculateOffsets) { offsets add(offset as Float) }
			temporary free()
		}
		(crossCorrelation, offsets)
	}
	// Assumes equi-distant samples
	// https://en.wikipedia.org/wiki/Spline_interpolation
	interpolateCubicSpline: func (numberOfPoints: Int) -> This {
		result := This new(this count + numberOfPoints * (this count - 1))
		thisPointer := this pointer as Float*
		coefficientMatrix := This _generateCubicSplineCoefficients(this count)
		rightHandSide := FloatMatrix new(1, this count) take()
		for (index in 0 .. this count)
			rightHandSide[0, index] = 3.f * (thisPointer[(this count - 1) minimum(index + 1)] - thisPointer[0 maximum(index - 1)])
		constants := coefficientMatrix solveTridiagonal(rightHandSide) take()
		coefficientMatrix free()
		rightHandSide free()

		for (index1 in 0 .. this count - 1) {
			result add(this[index1])
			a := constants[0, index1] - (thisPointer[index1 + 1] - thisPointer[index1])
			b := -constants[0, index1 + 1] + (thisPointer[index1 + 1] - thisPointer[index1])
			fraction := 1.f / (numberOfPoints + 1)
			for (index2 in 1 .. numberOfPoints + 1) {
				x := fraction * index2
				newValue := (1.f - x) * thisPointer[index1] + x * thisPointer[index1 + 1] + x * (1.f - x) * (a * (1.f - x) + b * x)
				result add(newValue)
			}
		}
		result add(thisPointer[this count - 1])
		constants free()
		result
	}
	// input: how many points there will be between two origin points.
	// this is a Linear interpolation way to have higher precision
	interpolateLinear: func (numberOfPoints: Int) -> This {
		result: This
		if (numberOfPoints > 0 && this count > 1) {
			result = This new(this count + numberOfPoints * (this count - 1))
			thisPointer := (this pointer as Float*)
			for (index1 in 0 .. this count - 1) {
				result add(thisPointer[index1])
				for (index2 in 1 .. numberOfPoints + 1)
					result add((index2 as Float / (numberOfPoints + 1) as Float) linearInterpolation(thisPointer[index1], thisPointer[index1 + 1]))
			}
			result add(thisPointer[this count - 1])
		} else
			result = this copy()
		result
	}
	scalarProduct: func (other: This) -> Float {
		result := 0.f
		for (i in 0 .. this count minimum(other count))
			result += this[i] * other[i]
		result
	}

	operator - -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(-this[i])
		result
	}
	operator + (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] + other[i])
		result
	}
	operator - (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] - other[i])
		result
	}
	operator * (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] * other[i])
		result
	}
	operator / (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] / other[i])
		result
	}
	operator || (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] > 0.0f ? 1.0f : (other[i] > 0.0f ? 1.0f : 0.0f))
		result
	}
	operator * (value: Float) -> This {
		result := This new(this _count)
		for (i in 0 .. this _count)
			result add(this[i] * value)
		result
	}
	operator / (value: Float) -> This {
		this * (1.0f / value)
	}
	operator + (value: Float) -> This {
		result := This new(this _count)
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

	getOnes: static func (count: Int) -> This {
		This new(count, 1.0f)
	}
	getZeros: static func (count: Int) -> This {
		result := This new(count)
		result _count = count
		result
	}
	gaussianKernel: static func ~defaultSigma (size: Int) -> This {
		This gaussianKernel(size, size as Float / 3.0f)
	}
	gaussianKernel: static func ~full (size: Int, sigma: Float) -> This {
		result := This new(size)
		factor := 1.0f / (sqrt(2.0f * Float pi) * sigma)
		for (i in 0 .. size)
			result add((factor * (Float e pow(-0.5f * ((i - (size - 1.0f) / 2.0f) squared) / (sigma squared)))) as Float)
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
				result += 1
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
				This _nthElement(array, start, pivot - 1, n)
			else
				This _nthElement(array, pivot + 1, end, n)
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
	_generateCubicSplineCoefficients: static func (size: Int) -> FloatMatrix {
		result := FloatMatrix new(size, size) take()
		result[0, 0] = 2.f
		result[0, 1] = 1.f
		for (index in 1 .. size - 1) {
			result[index, index - 1] = 1.f
			result[index, index] = 4.f
			result[index, index + 1] = 1.f
		}
		result[size - 1, size - 2] = 1.f
		result[size - 1, size - 1] = 2.f
		result
	}
	maximumDifference: func (other: This) -> Float {
		maximumDifference := 0.0f
		for (i in 0 .. (this count < other count ? this count : other count))
			maximumDifference = maximumDifference maximum((this[i] - other[i]) absolute)
		maximumDifference
	}
}
