
Queue: class <T> {
	_queue: T*
	_capacity: Int
	_count: Int
	_head := 0
	_tail := 0
	capacity ::= this _capacity
	count ::= this _count
	empty ::= this _count == 0
	full ::= this _count == this _capacity


	init: func (=_capacity) {
		this _queue = gc_calloc(capacity as SizeT, T size)
	}

	free: override func {
		gc_free(_queue)
		super()
	}

	enqueue: func (item: T) {
		if (!this full) {
			this _queue[this _tail] = item
			this _tail = (this _tail + 1) % this _capacity
			this _count += 1
		}
	}

	dequeue: func -> T {
		tempHead := this _head
		if (!this empty) {
			if (this _head != this _tail || this full)
				this _head = (this _head + 1) % this _capacity
			this _count -= 1
		}
		return this _queue[tempHead]
	}

	peek: func -> T {
		return this _queue[this _head]
	}
}
