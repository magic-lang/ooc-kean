/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Buffer: cover {
	_pointer: Pointer
	_size: Int
	pointer ::= this _pointer
	size ::= this _size
	init: func@ { this init(null, 0) }
	init: func@ ~allocate (size: Int) { this init(malloc(size), size) }
	init: func@ ~fromData (=_pointer, =_size)
	free: func@ -> Bool {
		result := this _pointer != null && this _size != 0
		if (result) {
			memfree(this _pointer)
			this _pointer = null
			this _size = 0
		}
		result
	}
	resize: func@ (size: Int) {
		newPointer := this _pointer
		if (size != this _size) {
			newPointer = realloc(this _pointer, size)
			this _size = size
		}
		this _pointer = newPointer
	}
	slice: func ~untilEnd (start: Int) -> This {
		this slice(start, this _size - start)
	}
	slice: func (start, distance: Int) -> This { // call by value -> modifies copy of cover
		size := distance absolute
		if (start < 0)
			start = this _size + start
		if (distance < 0)
			start -= size
		start < this size ? This new(this _pointer + start, size minimum(this _size - start)) : This empty
	}
	copy: func -> This { // call by value -> modifies copy of cover
		result: This
		if (this _pointer != null && this _size != 0) {
			result = This new(this _size)
			this copyTo(result)
		} else
			result = this
		result
	}
	copyTo: func (destination: This) -> Int {
		result := 0
		if (this _pointer != null && this _size != 0 && destination _pointer != null && destination _size != 0) {
			result = this _size minimum(destination _size)
			memcpy(destination _pointer, this _pointer, result)
		}
		result
	}
	reset: func (value: Int = 0) { memset(this _pointer, value, this _size) }

	operator == (other: This) -> Bool { this _size == other _size && memcmp(this _pointer, other _pointer, this _size) == 0 }
	operator [] (start: Int) -> This { this slice(start) }
	operator []= (start: Int, data: This) { data copyTo(this[start]) }
	operator [] (range: Range) -> This { this slice(range min, range count) }
	operator []= (range: Range, data: This) { data copyTo(this[range]) }

	empty: static This { get { This new() } }
}
