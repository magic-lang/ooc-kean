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
	init: func@ ~fromSize (size: Int) {
		this init(gc_malloc(size), size, Owner Caller)
	}
	init: func@ ~fromData (=_pointer, =_size, =_owner)
	take: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Callee && this _pointer != null)
			this _owner = Owner Caller
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		if (this _owner == Owner Caller && this _pointer != null)
			this _owner = Owner Callee
		this
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
	copy: func -> This { // call by value -> modifies copy of cover
		if (this _pointer != null && this _size != 0) {
			source := this _pointer
			this _pointer = gc_malloc(this _size)
			memcpy(this _pointer, source, this _size)
			this _owner = Owner Caller
		}
		this
	}
}
