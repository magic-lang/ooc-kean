/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Vector: abstract class <T> {
	_backend: T*
	_capacity: Int
	_freeContent: Bool
	capacity ::= this _capacity
	init: func ~preallocated (=_backend, =_capacity, freeContent := true)
	init: func (=_capacity, freeContent := true) { this _freeContent = freeContent }
	free: override func {
		memfree(this _backend)
		super()
	}
	_free: func ~range (start, end: Int) {
		if (this _freeContent && T inheritsFrom(Object))
			for (i in start .. end) {
				old := this[i] as Object
				if (old != null)
					old free()
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
	grow: func {
		this resize(this capacity < 512 ? this capacity * 2 : this capacity + 512)
	}
	move: func (sourceStart, targetStart: Int, capacity := 0) {
		if (capacity < 1)
			capacity = this capacity - sourceStart
		if (targetStart + capacity > this capacity)
			capacity = this capacity - targetStart
		memmove(this _backend + targetStart * T size, this _backend + sourceStart * T size, capacity * T size)
	}
	copy: abstract func -> This<T>
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
		version (safe)
			raise(index >= this capacity || index < 0, "Accessing Vector index out of range in get operator")
		this _backend[index]
	}
	operator []= (index: Int, item: T) {
		version (safe)
			raise(index >= this capacity || index < 0, "Accessing Vector index out of range in set operator")
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
		super(capacity)
		this _allocate(capacity)
	}
	copy: override func -> This<T> {
		result := This<T> new(this _capacity)
		this copy(0, result, 0)
		result
	}
	operator [] (index: Int) -> T {
		version (safe)
			raise(index >= this capacity || index < 0, "Accessing Vector index out of range in get operator")
		this _backend[index]
	}
	operator []= (index: Int, item: T) {
		version (safe)
			raise(index >= this capacity || index < 0, "Accessing Vector index out of range in set operator")
		if (this _freeContent && T inheritsFrom(Object)) {
			old := this[index] as Object
			if (old != null)
				old free()
		}
		this _backend[index] = item
	}
}
