/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

import math

Buffer: cover {
	_pointer: Pointer
	_size: Int
	pointer ::= this _pointer
	size ::= this _size
	init: func@ {
		this init(null, 0)
	}
	init: func@ ~allocate (size: Int) {
		this init(Pointer allocate(size), size)
	}
	init: func@ ~fromData (=_pointer, =_size)
	free: func@ -> Bool {
		result := this _pointer != null && this _size != 0 && this _pointer free()
		this _pointer = null
		this _size = 0
		result
	}
	reset: func { memset(this _pointer, 0, this _size) }
	reset: func ~value (value: Int) { memset(this _pointer, value, this _size) }
	slice: func ~untilEnd (start: Int) -> This {
		this slice(start, this _size - start)
	}
	slice: func (start, distance: Int) -> This { // call by value -> modifies copy of cover
		size := Int absolute(distance)
		if (start < 0)
			start = this _size + start
		if (distance < 0)
			start -= size
		start < this size ? This new(this _pointer + start, Int minimum(size, this _size - start)) : This empty
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
			result = Int minimum(this _size, destination _size)
			memcpy(destination _pointer, this _pointer, result)
		}
		result
	}
	operator [] (start: Int) -> This {
		this slice(start)
	}
	operator [] (range: Range) -> This {
		this slice(range min, range count)
	}
	operator []= (start: Int, data: This) {
		data copyTo(this[start])
	}
	operator []= (range: Range, data: This) {
		data copyTo(this[range])
	}
	operator == (other: This) -> Bool {
		(this _size == other _size) && (memcmp(this _pointer, other _pointer, this _size) == 0)
	}
	empty: static This { get { This new() } }
}
