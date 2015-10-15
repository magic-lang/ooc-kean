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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

import lang/Memory
use ooc-collections
import threading/Thread
import ReferenceCounter
import Debug

ByteBuffer: class {
	_pointer: UInt8*
	pointer ::= this _pointer
	_size: Int
	size ::= this _size
	_referenceCount: ReferenceCounter
	referenceCount ::= this _referenceCount
	_owner: Bool

	init: func (=_pointer, =_size, owner := false) {
		this _referenceCount = ReferenceCounter new(this)
		this _owner = owner
	}
	free: override func {
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
		if (this _owner) {
			gc_free(this _pointer)
			this _pointer = null
		}
		super()
	}
	zero: func ~whole {
		memset(_pointer, 0, _size)
	}
	zero: func ~range (offset, length: Int) {
		memset(_pointer + offset, 0, length)
	}
	slice: func (offset, size: Int) -> This {
		_SlicedByteBuffer new(this, offset, size)
	}
	copy: func -> This {
		result := This new(this size)
		memcpy(result pointer, this pointer, this size)
		result
	}
	copyTo: func ~untilEnd (other: This, start := 0, destination := 0) {
		a := this size - start
		b := other size - destination
		this copyTo(other, start, destination, a < b ? a : b)
	}
	copyTo: func (other: This, start: Int, destination: Int, length: Int) {
		memcpy(other pointer + destination, this pointer + start, length)
	}
	new: static func ~size (size: Int) -> This { _RecyclableByteBuffer new(size) }
	new: static func ~recover (pointer: UInt8*, size: Int, recover: Func (This)) -> This {
		_RecoverableByteBuffer new(pointer, size, recover)
	}
	clean: static func { _RecyclableByteBuffer _clean() }
}
_SlicedByteBuffer: class extends ByteBuffer {
	_parent: ByteBuffer
	_offset: Int
	init: func (=_parent, =_offset, size: Int) {
		_parent referenceCount increase()
		super(_parent pointer + _offset, size, false)
	}
	free: override func {
		if (this _parent != null)
			this _parent referenceCount decrease()
		this _parent = null
		this _pointer = null
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
		super()
	}
}
_RecoverableByteBuffer: class extends ByteBuffer {
	_recover: Func (ByteBuffer)
	init: func (pointer: UInt8*, size: Int, =_recover) { super(pointer, size, false) }
	free: override func {
		if ((this _recover as Closure) thunk) {
			this _recover(this)
		} else {
			raise("ByteBuffer __destroy__() has no thunk!")
		}
	}
}
_RecyclableByteBuffer: class extends ByteBuffer {
	_recyclable := true
	init: func (pointer: UInt8*, size: Int) { super(pointer, size, true) }
	free: override func {
		if (this _recyclable) {
			This _lock lock()
			bin := This _getBin(this size)
			while (bin count > 20) {
				version(debugByteBuffer) { Debug print("ByteBuffer bin full; freeing one ByteBuffer") }
				b := bin remove(0)
				b _recyclable = false
				b free()
			}
			this referenceCount _count = 0
			bin add(this)
			This _lock unlock()
		}
		else
			super()
	}

	// STATIC
	new: static func ~fromSize (size: Int) -> This {
		buffer: This = null
		bin := This _getBin(size)
		This _lock lock()
		for (i in 0 .. bin count) {
			if ((bin[i] size) == size) {
				buffer = bin remove(i)
				buffer referenceCount _count = 0
				break
			}
		}
		This _lock unlock()
		version(debugByteBuffer) { if (buffer == null) Debug print("No RecyclableByteBuffer available in the bin; allocating a new one") }
		buffer == null ? This new(gc_malloc_atomic(size), size) : buffer
	}
	_lock := static Mutex new()
	_smallRecycleBin := static VectorList<This> new()
	_mediumRecycleBin := static VectorList<This> new()
	_largeRecycleBin := static VectorList<This> new()
	_getBin: static func (size: Int) -> VectorList<This> {
		if (size < 10000)
			This _smallRecycleBin
		else if (size < 100000)
			This _mediumRecycleBin
		else
			This _largeRecycleBin
		//		size < 10000 ? This smallRecycleBin : size < 100000 ? This mediumRecycleBin : This largeRecycleBin
	}
	_cleanList: static func (list: VectorList<This>) {
		while (list count > 0) {
			b := list remove(0)
			b _recyclable = false
			b free()
		}
	}
	_clean: static func {
		This _cleanList(This _smallRecycleBin)
		This _cleanList(This _mediumRecycleBin)
		This _cleanList(This _largeRecycleBin)
		This _smallRecycleBin free()
		This _mediumRecycleBin free()
		This _largeRecycleBin free()
	}
}
