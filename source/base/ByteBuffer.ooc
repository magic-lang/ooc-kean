/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
import ReferenceCounter
import Debug

ByteBuffer: class {
	_pointer: Byte*
	_size: Int
	_referenceCount: ReferenceCounter
	_ownsMemory: Bool
	pointer ::= this _pointer
	size ::= this _size
	referenceCount ::= this _referenceCount

	init: func (=_pointer, =_size, ownsMemory := false) {
		this _referenceCount = ReferenceCounter new(this)
		this _ownsMemory = ownsMemory
	}
	free: override func {
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
		if (this _ownsMemory)
			memfree(this _pointer)
		this _pointer = null
		super()
	}
	zero: func ~whole { memset(this _pointer, 0, this _size) }
	zero: func ~range (offset, length: Int) { memset(this _pointer + offset, 0, length) }
	slice: func (offset, size: Int) -> This { _SlicedByteBuffer new(this, offset, size) }
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
	new: static func ~recover (pointer: Byte*, size: Int, recover: Func (This) -> Bool) -> This {
		_RecoverableByteBuffer new(pointer, size, recover)
	}
	free: static func ~all { _RecyclableByteBuffer _free~all() }
}

GlobalCleanup register(|| ByteBuffer free~all(), true)

_SlicedByteBuffer: class extends ByteBuffer {
	_parent: ByteBuffer
	_offset: Int
	init: func (=_parent, =_offset, size: Int) {
		_parent referenceCount increase()
		super(_parent pointer + _offset, size)
	}
	free: override func {
		if (this _parent != null)
			this _parent referenceCount decrease()
		this _parent = null
		super()
	}
}

_RecoverableByteBuffer: class extends ByteBuffer {
	_recover: Func (ByteBuffer) -> Bool
	init: func (pointer: Byte*, size: Int, =_recover) { super(pointer, size) }
	free: override func {
		if (!this _recover(this)) {
			(this _recover as Closure) free()
			super()
		}
	}
}

_RecyclableByteBuffer: class extends ByteBuffer {
	init: func (pointer: Byte*, size: Int) { super(pointer, size, true) }
	_forceFree: func {
		this _size = 0
		this free()
	}
	free: override func {
		if (this size > 0) {
			This _lock lock()
			bin := This _getBin(this size)
			while (bin count > 20) {
				version(debugByteBuffer) { Debug print("ByteBuffer bin full; freeing one ByteBuffer") }
				bin remove(0) _forceFree()
			}
			this referenceCount _count = 0
			bin add(this)
			This _lock unlock()
		}
		else
			super()
	}

	_lock := static Mutex new()
	_smallRecycleBin := static VectorList<This> new()
	_mediumRecycleBin := static VectorList<This> new()
	_largeRecycleBin := static VectorList<This> new()
	new: static func ~fromSize (size: Int) -> This {
		buffer: This = null
		bin := This _getBin(size)
		This _lock lock()
		for (i in 0 .. bin count)
			if ((bin[i] size) == size) {
				buffer = bin remove(i)
				buffer referenceCount _count = 0
				break
			}
		This _lock unlock()
		version(debugByteBuffer) { if (buffer == null) Debug print("No RecyclableByteBuffer available in the bin; allocating a new one") }
		buffer == null ? This new(malloc(size), size) : buffer
	}
	_getBin: static func (size: Int) -> VectorList<This> {
		size < 10000 ? This _smallRecycleBin : (size < 100000 ? This _mediumRecycleBin : This _largeRecycleBin)
	}
	_cleanList: static func (list: VectorList<This>) {
		while (list count > 0)
			list remove(0) _forceFree()
	}
	_free: static func ~all {
		This _cleanList(This _smallRecycleBin)
		This _cleanList(This _mediumRecycleBin)
		This _cleanList(This _largeRecycleBin)
		This _smallRecycleBin free()
		This _mediumRecycleBin free()
		This _largeRecycleBin free()
		if (This _lock != null) {
			This _lock free()
			This _lock = null
		}
	}
}
