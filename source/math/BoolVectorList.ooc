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
import FloatVectorList

BoolVectorList: class extends VectorList<Bool> {
	init: func ~default {
		this super()
	}
	init: func ~heap (capacity: Int){
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Bool>) {
		this super(other _vector)
		this _count = other count
	}
	totalTrues: func -> Int {
		result := 0
		for (i in 0 .. this count)
			result += (this[i] ? 1 : 0)
		result
	}
	totalFalses: func -> Int {
		this _count - totalTrues()
	}
	operator [] <T> (index: Int) -> T {
		this as VectorList<Bool> _vector[index]
	}
	operator []= (index: Int, item: Bool) {
		this _vector[index] = item
	}
	/*operator && (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] && other[i])
		result
	}
	operator || (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] || other[i])
		result
	}*/
	reverse: func -> This {
		result := This new(this _count)
		for (i in 1 .. (this _count + 1))
			result add(this[this _count - i])
		result
	}
	erosion: func (elementSize: Int) -> This {
		result := This new(this _count)
		halfSize := round((elementSize - 1) / 2) as Int
		currentSequence := This new()
		for (i in 0 .. this _count) {
			currentSequence = this getSlice((i - halfSize) clamp(0, this count - 1), (i + halfSize) clamp(0, this count - 1))
			result add(currentSequence totalTrues() == currentSequence count)
		}
		result
	}
	dilation: func (elementSize: Int) -> This {
		result := This new(this _count)
		halfSize := round((elementSize - 1) / 2) as Int
		currentSequence := This new()
		for (i in 0 .. this _count) {
			currentSequence = this getSlice((i - halfSize) clamp(0, this count - 1), (i + halfSize) clamp(0, this count - 1))
			result add(currentSequence totalTrues() > 0)
		}
		result
	}
	opening: func (elementSize: Int) -> This {
		erosion(elementSize) dilation(elementSize)
	}
	closing: func (elementSize: Int) -> This {
		dilation(elementSize) erosion(elementSize)
	}
	toFloatVectorList: func (floatForFalse := 0.0f, floatForTrue := 1.0f) -> FloatVectorList {
			result := FloatVectorList new(this _count)
		for (i in 0 .. this _count)
			result add(this[i] ? floatForTrue : floatForFalse)
		result
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	or: func (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] || other[i])
		result
	}
	and: func (other: This) -> This {
		minimumCount := this count < other count ? this count : other count
		result := This new(minimumCount)
		for (i in 0 .. minimumCount)
			result add(this[i] && other[i])
		result
	}
}
