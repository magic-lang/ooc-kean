
Queue: class <T> {
    _queue: T*
    _capacity: Int
    capacity ::= this _capacity
		_count: Int
		count ::= this _count
    _head: Int
    _tail: Int

    init: func (=_capacity) {
        this _queue = gc_calloc(capacity as SizeT, T size)
				this _head = 0
        this _tail = 0
    }

    free: override func {
				gc_free(_queue)
				super()
    }

    isEmpty: func -> Bool {
        this _count == 0
    }

    isFull: func -> Bool {
        this _count == this _capacity
    }

    add: func (item: T) {
        if (!this isFull()) {
            this _queue[this _tail] = item
            this _tail = (this _tail + 1) % this _capacity
            this _count += 1
        }
    }

    pop: func -> T {
        tempHead := this _head
        if (!this isEmpty()) {
            if (this _head != this _tail)
                this _head = (this _head + 1) % this _capacity
            this _count -= 1
        }
				return this _queue[tempHead]
    }

    peek: func -> T {
        return this _queue[this _head]
    }
}
