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
import FloatPoint2D
import FloatVectorList

FloatPoint2DVectorList: class extends VectorList<FloatPoint2D> {
	init: func ~default {
		super()
	}
	init: func ~fromVectorList (other: VectorList<FloatPoint2D>) {
		super(other _vector)
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
	_swap: static func (array: FloatPoint2D*, i, j: Int) {
		temporary := array[i]
		array[i] = array[j]
		array[j] = temporary
	}
	_partitionX: static func (array: FloatPoint2D*, start, end, pivot: Int) -> Int {
		pivotValue := array[pivot] x
		This _swap(array, pivot, end)
		result := start
		for (i in start .. end)
			if (array[i] x < pivotValue) {
				This _swap(array, result, i)
				++result
			}
		This _swap(array, result, end)
		result
	}
	_medianOfThreeX: static func (array: FloatPoint2D*, start, end: Int) -> Int {
		mid := (start + end) / 2
		if (array[start] x > array[mid] x)
			This _swap(array, mid, start)
		if (array[mid] x > array[end] x)
			This _swap(array, mid, end)
		if (array[start] x > array[end] x)
			This _swap(array, start, end)
		mid
	}
	_quicksortX: static func (array: FloatPoint2D*, start, end: Int) {
		if (end == start + 1 && array[start] x > array[end] x)
			This _swap(array, start, end)
		else if (start < end) {
			pivot := This _partitionX(array, start, end, This _medianOfThreeX(array, start, end))
			if (pivot > start)
				This _quicksortX(array, start, pivot - 1)
			if (pivot < end)
				This _quicksortX(array, pivot + 1, end)
		}
	}
	sortByX: func {
		This _quicksortX(this _vector _backend as FloatPoint2D*, 0, this count - 1)
	}
	operator + (value: FloatPoint2D) -> This {
		result := This new()
		thisPointer := this pointer as FloatPoint2D*
		for (i in 0 .. this count)
			result add(thisPointer[i] + value)
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
	resampleLinear: func (start, end, interval: Float) -> This {
		// Assumes list is sorted by x values.
		resultCount := ((end - start) / interval) ceil() as Int + 1
		result := This new()
		previousIndex := 0
		for (i in 0 .. resultCount) {
			point := FloatPoint2D new(start + i * interval, 0.0f)
			if (point x <= this[0] x)
				point y = this[0] y
			else if (point x >= this[this count - 1] x)
				point y = this[this count - 1] y
			else {
				leftPoint, rightPoint: FloatPoint2D
				for (j in previousIndex .. this count)
					if (this[j] x <= point x) {
						leftPoint = this[j]
						rightPoint = this[Int minimum(j + 1, this count - 1)]
						previousIndex = j
					} else break
				weight := Float absolute(point x - leftPoint x) / Float absolute(rightPoint x - leftPoint x)
				point y = Float linearInterpolation(leftPoint y, rightPoint y, weight)
			}
			result add(point)
		}
		result
	}
}
