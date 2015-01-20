/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

Vector: abstract class <T> {
	_backend: T*
	_capacity: Int
	capacity ::= this _capacity
	_freeContent: Bool

	init: /* protected */ func ~preallocated (=_backend, =_capacity, freeContent := true) {}
	init: /* protected */ func (=_capacity, freeContent := true) {
		this _allocate(this _capacity)
		this _freeContent = freeContent
	}
	__destroy__: func {	this _free(0, this capacity) }
	_free: func ~range (start: Int, end: Int) {
		if (this _freeContent && T inheritsFrom?(Object)) {
			for (i in start..end) {
					old := this[i] as Object
					old free()
			}
		}
	}
	_allocate: abstract func (capacity: Int)

	resize: func (capacity: Int) {
		if (capacity < this capacity) {
			this _free(capacity, this capacity)
			this _capacity = capacity
		}
		else if (capacity > this capacity) {
			this _allocate(capacity)
			this _capacity = capacity
		}
	}
	move: func (sourceStart: Int, targetStart: Int, capacity := 0) {
		if (capacity < 1)
			capacity = this capacity - sourceStart
		if (targetStart + capacity > this capacity)
			capacity = this capacity - targetStart
		memmove(this _backend + targetStart * T size, this _backend + sourceStart * T size, capacity * T size)
	}
	copy: func -> This<T> {
		result := HeapVector<T> new(this _capacity)
		this copy(0, result, 0)
		result
	}
	copy: func ~within (sourceStart: Int, targetStart: Int, capacity := 0) {
		this copy(sourceStart, this, targetStart, capacity)
	}
	copy: func ~to (sourceStart: Int, target: Vector<T>, targetStart: Int, capacity := 0) {
		if (capacity < 1)
			capacity = this capacity - sourceStart
		if (targetStart + capacity > target capacity)
			capacity = target capacity - targetStart

		source := this _backend + sourceStart * T size
		destination := target _backend + targetStart * T size
		length := capacity * T size

		if ((source <= destination && destination <= source + length) || (destination <= source && source <= destination + length))
			memmove(destination, source, length)
		else
			memcpy(destination, source, length)
	}
	operator [] (index: Int) -> T {
		this _backend[index]
	}

	operator []= (index: Int, item: T) {
		this _backend[index] = item
	}
}

HeapVector: class <T> extends Vector<T> {
	init: func(capacity: Int) {
		super(capacity)
	}

	_allocate: func(capacity: Int) {
		this _backend = gc_realloc(this _backend, capacity * T size)
	}

	__destroy__: func {
		gc_free(this _backend)
	}
}

StackVector: class <T> extends Vector<T> {
	init: func(data: T*, capacity: Int) {
		super(data, capacity)
	}

	// TODO: Why does this function exist here?
	_allocate: func(capacity: Int)
	
	resize: func(capacity: Int) {
		if (capacity > this capacity)
			capacity = this capacity
		super(capacity)
	}
}
