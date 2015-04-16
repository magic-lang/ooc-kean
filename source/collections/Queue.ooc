
Queue: class <T> {
	_queue: T*
	_capacity := 0
	_count := 0
	_head := 0
	_tail := 0
	capacity: Int { get { this capacity() }}
	count: Int { get { this count() }}
	empty: Bool { get {this empty() }}
	full: Bool { get { this full() }}

	init: func (=_capacity) {
		this _queue = gc_calloc(capacity as SizeT, T size)
	}

	free: override func {
		gc_free(_queue)
		super()
	}

	enqueue: virtual func (item: T) {
		if (!this full()) {
			this _queue[this _tail] = item
			this _tail = (this _tail + 1) % this _capacity
			this _count += 1
		} else
			raise("Trying to enqueue something on a full queue")
	}

	dequeue: virtual func -> T {
		if (!this empty()) {
			tempHead := this _head
			if (this _head != this _tail || this full())
				this _head = (this _head + 1) % this _capacity
			this _count -= 1
			return this _queue[tempHead]
		} else
			raise("Trying to dequeue something from an empty queue")
	}

	peek: virtual func -> T {
		if (!this empty())
			return this _queue[this _head]
		else
			raise("Trying to peek on an empty queue")
	}

	capacity: func -> Int {
		this _capacity
	}

	count: func -> Int {
		this _count
	}

	empty: func -> Bool {
		this _count == 0
	}

	full: func -> Bool {
		this _count == this _capacity
	}
}
