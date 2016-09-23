/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
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
	reverse: override func -> This {
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
	toString: func (separator := "\n") -> String {
		result := this _count > 0 ? this[0] toString() : ""
		result = this _count > 1 ? (result + separator) >> this[1] toString() : result
		for (i in 2 .. this _count)
			result = (result >> separator) >> this[i] toString()
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
