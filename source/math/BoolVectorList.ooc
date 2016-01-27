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
use base
use collections
import FloatVectorList

BoolVectorList: class extends VectorList<Bool> {
	init: func ~default {
		super()
	}
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Bool>) {
		super(other _vector)
		this _count = other count
	}
	tally: func (tallyTrues: Bool) -> Int {
		trues := 0
		for (i in 0 .. this count)
			trues += (this[i] ? 1 : 0)
		tallyTrues ? trues : this _count - trues
	}
	reverse: func -> This {
		super() as This
	}
	erosion: func (structuringElementSize: Int) -> This {
		result := This new(this _count)
		halfSize := ((structuringElementSize - 1) / 2.f) round() as Int
		currentSequence := This new(structuringElementSize)
		for (i in 0 .. this _count) {
			startIndex := (i - halfSize) clamp(0, this count - 1)
			endIndex := (i + halfSize) clamp(0, this count - 1)
			this getSliceInto(startIndex, endIndex, (currentSequence as This))
			result add(currentSequence tally(true) == currentSequence count)
		}
		currentSequence free()
		result
	}
	dilation: func (structuringElementSize: Int) -> This {
		result := This new(this _count)
		halfSize := ((structuringElementSize - 1) / 2.f) round() as Int
		currentSequence := This new(structuringElementSize)
		for (i in 0 .. this _count) {
			startIndex := (i - halfSize) clamp(0, this count - 1)
			endIndex := (i + halfSize) clamp(0, this count - 1)
			this getSliceInto(startIndex, endIndex, (currentSequence as This))
			result add(currentSequence tally(true) > 0)
		}
		currentSequence free()
		result
	}
	opening: func (structuringElementSize: Int) -> This {
		erodedList := this erosion(structuringElementSize)
		result := erodedList dilation(structuringElementSize)
		erodedList free()
		result
	}
	closing: func (structuringElementSize: Int) -> This {
		dilatedList := this dilation(structuringElementSize)
		result := dilatedList erosion(structuringElementSize)
		dilatedList free()
		result
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
	toText: func -> Text {
		result: Text
		textBuilder := TextBuilder new()
		for (i in 0 .. this _count)
			textBuilder append(this[i] toText())
		result = textBuilder join(t"\n")
		textBuilder free()
		result
	}

	operator [] <T> (index: Int) -> T { this as VectorList<Bool> _vector[index] }
	operator []= (index: Int, item: Bool) { this _vector[index] = item }
	operator && (other: This) -> This {
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
	}
}
