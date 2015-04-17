
Queue: abstract class <T> {
	_count := 0
	count ::= this _count
	empty ::= this count == 0
	init: func
	clear: abstract func
	//FIXME: This should be abstract but it messes up for sub-subclasses that overrides
	enqueue: virtual func (item: T)
	//TODO: This is how we want it to look but we get problems compiling
	dequeue: abstract func -> (T, Bool)
	peek: abstract func -> (T, Bool)
	//TODO: This works much better and will do for now
	dequeue: abstract func ~out (result: T*) -> Bool
	peek: abstract func ~out (result: T*) -> Bool

	//new: static func -> Queue<T> { VectorQueue<T> new() }
}

VectorQueue: class <T> extends Queue<T> {
	_backend: T*
	_capacity := 0
	_head := 0
	_tail := 0
	capacity ::= this _capacity
	count ::= this _count
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
	enqueue: override func (item: T) {
		if (this full)
			this _resize()
		this _backend[this _tail] = item
		this _tail = (this _tail + 1) % this _capacity
		this _count += 1
	}
	dequeue: func ~out (result: T*) -> Bool {
		success := true
		if (this empty)
			success = false
		else {
			result = this _backend[this _head]
			this _count -= 1
			this _head = (this _head + 1) % this _capacity
		}
		success
	}
	dequeue: func -> (T, Bool) {
		result: T
		success := this dequeue(result&)
		(result, success)
	}
	peek: func ~out (result: T*) -> Bool {
		success := true
		if (this empty)
			success = false
		else
			result = this _backend[this _head]
		success
	}
	peek: func -> (T, Bool) {
		result: T
		success := this peek(result&)
		(result, success)
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
	toString: func -> String { "Queue: count=%d capacity=%d" format(this _count, this _capacity) }
}
