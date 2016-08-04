/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

VectorQueue: class <T> extends Queue<T> {
	_backend: T*
	_capacity := 0
	_head := 0 // Index of oldest element
	_tail := 0 // Index of newest element
	_chunkCount := 32
	capacity ::= this _capacity
	isFull ::= this _count == this _capacity

	init: func (capacity := 32) {
		this _capacity = capacity
		this _backend = calloc(capacity as SizeT, T size)
		super()
	}
	free: override func {
		memfree(this _backend)
		super()
	}
	clear: override func {
		this _head = 0
		this _tail = 0
		this _count = 0
	}
	enqueue: override func (item: T) {
		if (this isFull)
			this _resize()
		this _backend[this _tail] = item
		this _tail = (this _tail + 1) % this _capacity
		this _count += 1
	}
	dequeue: override func ~default (fallback: T) -> T {
		result := this peek(fallback)
		if (!this empty) {
			this _count -= 1
			this _head = (this _head + 1) % this _capacity
		}
		result
	}
	peek: override func ~default (fallback: T) -> T {
		result: T
		if (this empty)
			result = fallback
		else
			result = this _backend[this _head]
		result
	}
	_resize: func {
		oldCapacity := this _capacity
		newCapacity := this _capacity + this _chunkCount
		moveCount := oldCapacity - this _head
		bytes := newCapacity * T size
		this _backend = realloc(this _backend, bytes)
		sourcePtr: Byte* = this _backend as Byte* + (this _head * T size)
		destinationPtr := sourcePtr + (this _chunkCount * T size)
		memmove(destinationPtr, sourcePtr, moveCount * T size)
		this _head += this _chunkCount
		this _capacity = newCapacity
	}
	toString: func -> String { "Queue: count=" << this _count toString() >> " capacity=" & this _capacity toString() }

	operator [] (index: Int) -> T {
		version(safe)
			raise(index < -this count || index >= this count, "Indexing in get accessor of VectorQueue outside of range.")
		position := (index >= 0 ? this _head + index : this _tail + index) modulo(this _capacity)
		this _backend[position]
	}
	operator []= (index: Int, value: T) {
		version(safe)
			raise(index < -this count || index >= this count, "Indexing in set accessor of VectorQueue outside of range.")
		position := (index >= 0 ? this _head + index : this _tail + index) modulo(this _capacity)
		this _backend[position] = value
	}
}
