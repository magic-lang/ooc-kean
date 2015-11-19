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

TextBuffer: cover {
	_backend: OwnedBuffer
	raw: Char* { get {
		result := this _backend pointer as Char*
		this free(Owner Receiver)
		result
	}}
	count: Int { get {
		result := this _backend size
		this free(Owner Receiver)
		result
	}}
	owner: Owner { get {
		result := this _backend owner
		this free(Owner Receiver)
		result
	}}
	isOwned: Bool { get {
		result := this _backend isOwned
		this free(Owner Receiver)
		result
	}}
	init: func@ ~empty { this init(OwnedBuffer new()) }
	init: func@ ~fromSize (size: Int) { this init(OwnedBuffer new(size)) }
	init: func@ ~fromData (data: Char*, count: Int, owner := Owner Unknown) {
		this init(OwnedBuffer new(data as UInt8*, count, owner))
	}
	init: func@ ~fromBuffer (buffer: Buffer) { this init(buffer data, buffer size) }
	init: func@ (=_backend)
	take: func -> This { // call by value -> modifies copy of cover
		this _backend = this _backend take()
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		this _backend = this _backend give()
		this
	}
	claim: func -> This { // call by value -> modifies copy of cover
		this _backend = this _backend claim()
		this
	}
	free: func@ -> Bool { this _backend free() }
	free: func@ ~withCriteria (criteria: Owner) -> Bool { this _backend free(criteria) }
	slice: func ~untilEnd (start: Int) -> This {
		this _backend = this _backend slice(start)
		this
	}
	slice: func (start, distance: Int) -> This { // call by value -> modifies copy of cover
		this _backend = this _backend slice(start, distance)
		this
	}
	copy: func -> This { // call by value -> modifies copy of cover
		this _backend = this _backend copy()
		this
	}
	copyTo: func (destination: This) -> Int { this _backend copyTo(destination _backend) }
	toString: func -> String {
		t := this take()
		result := Buffer new()
		result append(t raw, t count)
		this free(Owner Receiver)
		String new(result)
	}
	operator [] (index: Int) -> Char { this raw[index] }
	operator [] (range: Range) -> This { this slice(range min, range max - range min) }
	operator []= (index: Int, value: Char) { this raw[index] = value }
	operator []= (range: Range, data: This) { data copyTo(this[range]) }
	operator == (other: This) -> Bool {
		result := this _backend == other _backend
		if (this _backend _pointer != other _backend _pointer)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	operator + (other: This) -> This {
		result := This new(this take() count + other take() count)
		this copyTo(result)
		other copyTo(result slice(this take() count))
		if (this _backend _pointer != other _backend _pointer)
			other free(Owner Receiver)
		this free(Owner Receiver)
		result
	}
	empty: static This { get { This new() } }
}
