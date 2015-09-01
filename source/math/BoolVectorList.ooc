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
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Bool>) {
		this super(other _vector)
		this _count = other count
	}
	tally: func (tallyTrues: Bool) -> Int {
		trues := 0
		for (i in 0 .. this count)
			trues += (this[i] ? 1 : 0)
		tallyTrues ? trues : this _count - trues
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
	erosion: func (structuringElementSize: Int) -> This {
		result := This new(this _count)
		halfSize := round((structuringElementSize - 1) / 2) as Int
		currentSequence := This new(structuringElementSize)
		for (i in 0 .. this _count) {
			startIndex := (i - halfSize) clamp(0, this count - 1)
			endIndex := (i + halfSize) clamp(0, this count - 1)
			this getSliceInto(startIndex, endIndex, (currentSequence as This)&)
			result add(currentSequence tally(true) == currentSequence count)
		}
		result
	}
	dilation: func (structuringElementSize: Int) -> This {
		result := This new(this _count)
		halfSize := round((structuringElementSize - 1) / 2) as Int
		currentSequence := This new(structuringElementSize)
		for (i in 0 .. this _count) {
			startIndex := (i - halfSize) clamp(0, this count - 1)
			endIndex := (i + halfSize) clamp(0, this count - 1)
			this getSliceInto(startIndex, endIndex, (currentSequence as This)&)
			result add(currentSequence tally(true) > 0)
		}
		result
	}
	opening: func (structuringElementSize: Int) -> This {
		this erosion(structuringElementSize) dilation(structuringElementSize)
	}
	closing: func (structuringElementSize: Int) -> This {
		this dilation(structuringElementSize) erosion(structuringElementSize)
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
