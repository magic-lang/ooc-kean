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
	_freeContent: Bool
	capacity ::= this _capacity
	init: func ~preallocated (=_backend, =_capacity, freeContent := true)
	init: func (=_capacity, freeContent := true) {
		this _freeContent = freeContent
	}
	free: override func {
		if (!(this instanceOf?(StackVector)))
			memfree(this _backend)
		super()
	}
	_free: func ~range (start, end: Int) {
		if (this _freeContent && T inheritsFrom?(Object)) {
			for (i in start .. end) {
				old := this[i] as Object
				if (old != null)
					old free()
			}
		}
	}
	resize: virtual func (capacity: Int) {
		if (capacity < this capacity) {
			this _free(capacity, this capacity)
			this _capacity = capacity
		}
		else if (capacity > this capacity)
			this _capacity = capacity
	}
	move: func (sourceStart, targetStart: Int, capacity := 0) {
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
	copy: func ~within (sourceStart, targetStart: Int, capacity := 0) {
		this copy(sourceStart, this as This<T>, targetStart, capacity)
	}
	copy: func ~to (sourceStart: Int, target: This<T>, targetStart: Int, capacity := 0) {
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
		version (safe) {
			if (index >= this capacity || index < 0)
				raise("Accessing Vector index out of range in get operator")
		}
		this _backend[index]
	}

	operator []= (index: Int, item: T) {
		version (safe) {
			if (index >= this capacity || index < 0)
				raise("Accessing Vector index out of range in set operator")
		}
		this _backend[index] = item
	}
}

HeapVector: class <T> extends Vector<T> {
	init: func (capacity: Int, freeContent := true) {
		super(capacity, freeContent)
		this _allocate(capacity)
		memset(this _backend, 0, capacity * T size)
	}

	_allocate: func (capacity: Int) {
		this _backend = realloc(this _backend, capacity * T size)
	}

	resize: override func (capacity: Int) {
		super()
		this _allocate(capacity)
	}

	operator [] (index: Int) -> T {
		version (safe) {
			if (index >= this capacity || index < 0)
				raise("Accessing Vector index out of range in get operator")
		}
		this _backend[index]
	}

	operator []= (index: Int, item: T) {
		version (safe) {
			if (index >= this capacity || index < 0)
				raise("Accessing Vector index out of range in set operator")
		}
		if (this _freeContent && T inheritsFrom?(Object)) {
			old := this[index] as Object
			if (old != null)
				old free()
		}
		this _backend[index] = item
	}
}

StackVector: class <T> extends Vector<T> {
	init: func (data: T*, capacity: Int) {
		super(data, capacity)
	}
	resize: override func (capacity: Int) {
		if (capacity > this capacity)
			capacity = this capacity
		super(capacity)
	}
}
