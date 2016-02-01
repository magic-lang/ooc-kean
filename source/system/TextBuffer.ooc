/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Owner
import OwnedBuffer

TextBuffer: cover {
	_backend: OwnedBuffer
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
		this init(OwnedBuffer new(data as Byte*, count, owner))
	}
	init: func@ ~fromBuffer (buffer: CharBuffer) { this init(buffer data, buffer size) }
	init: func@ (=_backend)
	free: func@ -> Bool { this _backend free() }
	free: func@ ~withCriteria (criteria: Owner) -> Bool { this _backend free(criteria) }
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
		result := CharBuffer new()
		result append(t _backend pointer as Char*, t count)
		this free(Owner Receiver)
		String new(result)
	}

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
	operator [] (index: Int) -> Char { (this _backend pointer as Char*)[index] }
	operator []= (index: Int, value: Char) { (this _backend pointer as Char*)[index] = value }
	operator [] (range: Range) -> This { this slice(range min, range max - range min) }
	operator []= (range: Range, data: This) { data copyTo(this[range]) }

	empty: static This { get { This new() } }
}
