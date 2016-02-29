/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Stack: class <T> {
	_data: T*
	_count: SizeT = 0
	_capacity: SizeT = 8
	count ::= this _count
	isEmpty ::= this count == 0
	top ::= this peek()
	init: func {
		this _data = calloc(this _capacity, T size)
	}
	free: override func {
		memfree(this _data)
		super()
	}
	push: func (element: T) {
		if (this _count >= this _capacity)
			this _grow()
		this _data[this _count] = element
		++this _count
	}
	pop: func -> T {
		version(safe)
			raise(this isEmpty, "Trying to pop an empty stack.", This)
		this _data[--this _count]
	}
	peek: func (index := 0) -> T {
		version(safe) {
			raise(index < 0, "Trying to peek(%d)! index must be >= 1 <= size" format(index), This)
			raise(index >= this _count, "Trying to peek(%d) a stack of size %d" format(index, this _count), This)
		}
		this _data[this _count - index - 1]
	}
	clear: func {
		this _count = 0
	}
	_grow: func {
		if (this _capacity < 4096)
			this _capacity *= 2
		else
			this _capacity += 2048
		this _data = realloc(this _data, this _capacity * T size)
	}
}
