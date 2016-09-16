/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
import Allocator
import ReferenceCounter
import Debug

ByteBuffer: class {
	_pointer: Byte*
	_size: Int
	_referenceCount: ReferenceCounter
	_ownsMemory: Bool
	_allocator: AbstractAllocator
	pointer ::= this _pointer
	size ::= this _size
	referenceCount ::= this _referenceCount

	init: func (=_pointer, =_size, ownsMemory := false, allocator := Allocator defaultAllocator()) {
		this _referenceCount = ReferenceCounter new(this)
		this _ownsMemory = ownsMemory
		this _allocator = allocator
	}
	free: override func {
		if (this _referenceCount != null)
			this _referenceCount free()
		this _referenceCount = null
		if (this _ownsMemory)
			this _allocator deallocate(this _pointer)
		this _pointer = null
		this _allocator free(Owner Receiver)
		super()
	}
	zero: func ~whole { this memset(0) }
	zero: func ~range (offset, length: Int) { this memset(offset, length, 0) }
	memset: func ~whole (value: Byte) { memset(this _pointer, value, this _size) }
	memset: func ~range (offset, length: Int, value: Byte) { memset(this _pointer + offset, value, length) }
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
	new: static func ~size (size: Int, allocator := Allocator defaultAllocator()) -> This { This new(allocator allocate(size) as Byte*, size, true, allocator) }
	new: static func ~recover (pointer: Byte*, size: Int, recover: Func (This) -> Bool) -> This { _RecoverableByteBuffer new(pointer, size, recover) }
}

GlobalCleanup register(|| Allocator free~all(), 9)

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
