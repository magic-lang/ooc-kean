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

use ooc-base
import math

OwnedBuffer: cover {
	_pointer: UInt8*
	_size: Int
	_owner: Owner
	pointer ::= this _pointer
	size ::= this _size
	owner ::= this _owner
	isOwned ::= this _owner != Owner Unknown && this _owner != Owner Static && this _owner != Owner Stack && this _pointer != null
	init: func@ {
		this init(null, 0, Owner Unknown)
	}
	init: func@ ~fromSize (size: Int, owner := Owner Receiver) {
		this init(gc_malloc(size), size, owner)
	}
	init: func@ ~fromData (=_pointer, =_size, =_owner)
	take: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Receiver && this _pointer != null)
			this _owner = Owner Sender
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Sender && this _pointer != null)
			this _owner = Owner Receiver
		this
	}
	claim: func -> This {
		this isOwned ? this : this copy()
	}
	free: func@ -> Bool {
		result: Bool
		if (result = this isOwned)
			gc_free(this _pointer)
		this _pointer = null
		this _size = 0
		this _owner = Owner Unknown
		result
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _owner == criteria && this free()
	}
	slice: func ~untilEnd (start: Int) -> This {
		this slice(start, this _size - start)
	}
	slice: func (start, distance: Int) -> This { // call by value -> modifies copy of cover
		size := abs(distance)
		if (start < 0)
			start = this _size + start
		if (distance < 0)
			start -= size
		start < this size ? This new(this _pointer + start, Int minimum~two(size, this _size - start), Owner Unknown) : This empty
	}
	copy: func -> This { // call by value -> modifies copy of cover
		result: This
		if (this _pointer != null && this _size != 0) {
			result = This new(this _size)
			this copyTo(result)
			this _owner = Owner Receiver
		} else
			result = this
		result
	}
	copyTo: func (destination: This) -> Int {
		result := 0
		version (safe) {
			if (destination _owner == Owner Static)
				raise("Can not copy to static memory.")
		}
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
