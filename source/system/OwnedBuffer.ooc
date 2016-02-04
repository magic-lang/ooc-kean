/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Owner

OwnedBuffer: cover {
	_pointer: Byte*
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
		this init(calloc(1, size), size, owner)
	}
	init: func@ ~fromData (=_pointer, =_size, =_owner)
	free: func@ -> Bool {
		result := this isOwned
		if (result)
			memfree(this _pointer)
		this _pointer = null
		this _size = 0
		this _owner = Owner Unknown
		result
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _owner == criteria && this free()
	}
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
	slice: func ~untilEnd (start: Int) -> This {
		this slice(start, this _size - start)
	}
	slice: func (start, distance: Int) -> This { // call by value -> modifies copy of cover
		size := distance abs() as Int
		if (start < 0)
			start = this _size + start
		if (distance < 0)
			start -= size
		start < this size ? This new(this _pointer + start, size minimum(this _size - start), Owner Unknown) : This empty
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
		version (safe)
			raise(destination _owner == Owner Static, "Can not copy to static memory.")
		if (this _pointer != null && this _size != 0 && destination _pointer != null && destination _size != 0) {
			result = this _size minimum(destination _size)
			memcpy(destination _pointer, this _pointer, result)
		}
		result
	}

	operator == (other: This) -> Bool { (this _size == other _size) && (memcmp(this _pointer, other _pointer, this _size) == 0) }
	operator [] (start: Int) -> This { this slice(start) }
	operator []= (start: Int, data: This) { data copyTo(this[start]) }
	operator [] (range: Range) -> This { this slice(range min, range count) }
	operator []= (range: Range, data: This) { data copyTo(this[range]) }

	empty: static This { get { This new() } }
}
