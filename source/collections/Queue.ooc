import math

Queue: abstract class <T> {
	_count := 0
	count ::= this _count
	empty ::= this count == 0
	init: func
	clear: abstract func
	enqueue: abstract func (item: T)
	dequeue: abstract func ~default (fallback: T) -> T
	peek: abstract func ~default (fallback: T) -> T
}

VectorQueue: class <T> extends Queue<T> {
	_backend: T*
	_capacity := 0
	_head := 0 // Index of oldest element
	_tail := 0 // Index of newest element
	capacity ::= this _capacity
	full ::= this _count == this _capacity
	_chunkCount := 32

	init: func (capacity := 32) {
		this _capacity = capacity
		this _backend = gc_calloc(capacity as SizeT, T size)
		super()
	}
	free: override func {
		gc_free(_backend)
		super()
	}
	clear: func {
		this _head = 0
		this _tail = 0
		this _count = 0
	}
	enqueue: func (item: T) {
		if (this full)
			this _resize()
		this _backend[this _tail] = item
		this _tail = (this _tail + 1) % this _capacity
		this _count += 1
	}
	dequeue: func ~default (fallback: T) -> T {
		result := this peek(fallback)
		if (!this empty) {
			this _count -= 1
			this _head = (this _head + 1) % this _capacity
		}
		result
	}
	peek: func ~default (fallback: T) -> T {
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
		this _backend = gc_realloc(this _backend, bytes)
		sourcePtr: UInt8* = this _backend as UInt8* + (this _head * T size)
		destinationPtr := sourcePtr + (this _chunkCount * T size)
		memmove(destinationPtr, sourcePtr, moveCount * T size)
		this _head += this _chunkCount
		this _capacity = newCapacity
	}
	toString: func -> String { "Queue: count=" << this _count toString() >> " capacity=" & this _capacity toString() }
	operator [] (index: Int) -> T {
		version(safe)
			if (index < -this count || index >= this count)
				raise("Indexing in get accessor of VectorQueue outside of range.")
		position := (index >= 0 ? this _head + index : this _tail + index) modulo(this _capacity)
		this _backend[position]
	}
}
