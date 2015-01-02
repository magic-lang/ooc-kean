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
import structs/FreeArrayList
import threading/Thread
import ReferenceCounter

ByteBuffer: class {
	_pointer: UInt8*
	pointer ::= this _pointer
	_size: Int
	size ::= this _size
	_referenceCount: ReferenceCounter
	referenceCount ::= this _referenceCount
	init: func(=_pointer, =_size) {
		this _referenceCount = ReferenceCounter new(this)
	}
	__destroy__: func {
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
		gc_free(this _pointer)
		this _pointer = null
		super()
	}

	slice: func(offset: Int, size: Int) -> This {
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
	new: static func ~size (size: Int) -> This {
		_RecyclableByteBuffer new(size)
	}
	new: static func ~recover (pointer: UInt8*, size: Int, recover: Func (This)) -> This {
		_RecoverableByteBuffer new(pointer, size, recover)
	}
	clean: static func {
		_RecyclableByteBuffer _clean()
	}
}
_SlicedByteBuffer: class extends ByteBuffer {
	_parent: ByteBuffer
	_offset: Int
	init: func (=_parent, =_offset, size: Int) {
		_parent referenceCount increase()
		super(_parent pointer + _offset, size)
	}
	__destroy__: func {
		if (this _parent != null)
			this _parent referenceCount decrease()
		this _parent = null
		this _pointer = null
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
	}
}
_RecoverableByteBuffer: class extends ByteBuffer {
	_recover: Func (ByteBuffer)
	init: func (pointer: UInt8*, size: Int, =_recover) {
		super(pointer, size)
	}
	free: func {
		if ((this _recover as Closure) thunk) {
			this _recover(this)
		} else {
			raise("ByteBuffer __destroy__() has no thunk!")
		}
	}
}
_RecyclableByteBuffer: class extends ByteBuffer {
	init: func (pointer: UInt8*, size: Int) {
		super(pointer, size)
	}
	free: func {
		This _lock lock()
		bin := This _getBin(this size)
		while (bin size > 10) {
			b := bin get(0)
			bin removeAt(0, false)
			b __destroy__()
		}
		this referenceCount _count = 0
		bin add(this)
		This _lock unlock()
	}
	
	__destroy__: func {
		super()
		// This is called by Object free(), which we've overridden,
		// so we we have to do it manually
		gc_free(this)
	}

	// STATIC
	new: static func ~fromSize (size: Int) -> This {
		buffer: This = null
		bin := This _getBin(size)
		This _lock lock()
		for(i in 0..bin size)
		{
			if ((bin[i] size) == size) {
				buffer = bin[i]
				bin removeAt(i, false)
				buffer referenceCount _count = 0
				break
			}
		}
		This _lock unlock()
		buffer == null ? This new(gc_malloc_atomic(size), size) : buffer
	}
	_lock := static Mutex new()
	_smallRecycleBin := static FreeArrayList<This> new()
	_mediumRecycleBin := static FreeArrayList<This> new()
	_largeRecycleBin := static FreeArrayList<This> new()
	_getBin: static func (size: Int) -> FreeArrayList<This> {
		if (size < 10000)
			This _smallRecycleBin
		else if (size < 100000)
			This _mediumRecycleBin
		else
			This _largeRecycleBin
		//		size < 10000 ? This smallRecycleBin : size < 100000 ? This mediumRecycleBin : This largeRecycleBin
	}
	_clean: static func {
		while (This _smallRecycleBin size > 0) {
			b := This _smallRecycleBin get(0)
			This _smallRecycleBin removeAt(0, false)
			b __destroy__()
		}
		gc_free(This _smallRecycleBin data)
		gc_free(This _smallRecycleBin)
		while (This _mediumRecycleBin size > 0) {
			b := This _mediumRecycleBin get(0)
			This _mediumRecycleBin removeAt(0, false)
			b __destroy__()
		}
		gc_free(This _mediumRecycleBin data)
		gc_free(This _mediumRecycleBin)
		while (This _largeRecycleBin size > 0) {
			b := This _largeRecycleBin get(0)
			This _largeRecycleBin removeAt(0, false)
			b __destroy__()
		}
		gc_free(This _largeRecycleBin data)
		gc_free(This _largeRecycleBin)
	}
}
