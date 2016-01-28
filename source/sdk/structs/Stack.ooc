Stack: class <T> {
	_data: T*
	_size: SizeT = 0
	_capacity: SizeT = 8
	size ::= this _size
	isEmpty ::= this size == 0
	top ::= this peek()
	init: func {
		this _data = calloc(this _capacity, T size)
	}
	free: override func {
		memfree(this _data)
		super()
	}
	push: func (element: T) {
		if (this size >= this _capacity)
			this _grow()
		this _data[this size] = element
		++this _size
	}
	pop: func -> T {
		version(safe)
			if (this isEmpty)
				Exception new(This, "Trying to pop an empty stack.") throw()
		this _data[--this _size]
	}
	peek: func (index := 0) -> T {
		version(safe)
			if (index < 0)
				Exception new(This, "Trying to peek(%d)! index must be >= 1 <= size" format(index)) throw()
			else if (index >= this size)
				Exception new(This, "Trying to peek(%d) a stack of size %d" format(index, this size)) throw()
		this _data[this size - index - 1]
	}
	clear: func {
		this _size = 0
	}
	_grow: func {
		if (this _capacity < 4096)
			this _capacity *= 2
		else
			this _capacity += 2048
		this _data = realloc(this _data, this _capacity * T size)
	}
}
