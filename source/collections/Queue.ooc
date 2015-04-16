

Queue: class <T> {
	_backend: T*
	_capacity := 0
	_count := 0
	_head := 0
	_tail := 0
	capacity ::= this _capacity
	count ::= this _count
	empty ::= this _count == 0
	full ::= this _count == this _capacity
	_chunkCount := 32

	init: func (capacity := 32) {
		this _capacity = capacity
		this _backend = gc_calloc(capacity as SizeT, T size)
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
	enqueue: virtual func (item: T) {
		if (this full)
			this _resize()
		this _backend[this _tail] = item
		this _tail = (this _tail + 1) % this _capacity
		this _count += 1
	}
	dequeue: virtual func -> T {
		result: T
		if (this empty)
			raise("Trying to dequeue something from an empty queue")
		else {
			result = this _backend[this _head]
			this _count -= 1
			this _head = (this _head + 1) % this _capacity
		}
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
	peek: virtual func -> T {
		if (!this empty)
			return this _backend[this _head]
		else
			raise("Trying to peek on an empty queue")
	}
	toString: func -> String {
		result := "Queue: count=%d capacity=%d" format(this _count, this _capacity)
		/*for (i in 0..this _count) {
			index := (i + this _head) % this _capacity
			result += ("Value %d = " format(i))
			value := this _backend[index]
			temp: Int = 0
			temp += (value as Int)
			result += temp toString() + "\n"
		}*/
		result
	}
}
