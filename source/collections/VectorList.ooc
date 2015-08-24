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

import Vector
import math

VectorList: class <T> {
	_vector: Vector<T>
	_count: Int
	count ::= this _count
	pointer ::= this _vector _backend as Pointer
	empty ::= this _count == 0
	init: func ~default {
		this init(32)
	}
	init: func ~heap (capacity: Int, freeContent := true) {
		this init(HeapVector<T> new(capacity, freeContent))
	}
	init: func (=_vector)

	add: func (item: T) {
		if (this _vector capacity <= this _count)
			this _vector resize(this _vector capacity + 8)
		this _vector[this _count] = item
		this _count += 1
	}
	append: func (other: This<T>) {
		if (this _vector capacity < this _count + other count)
			this _vector resize(this _vector capacity + other count)
		for (i in 0 .. other count)
			this _vector[this _count + i] = other[i]
		this _count += other count
	}
	insert: func (index: Int, item: T) {
		if (this _vector capacity <= this _count)
			this _vector resize(this _vector capacity + 8)
		this _vector copy(index, index + 1)
		this _vector[index] = item
		this _count += 1
	}
	remove: func ~last -> T {
		this _count -= 1
		this _vector[this _count]
	}
	remove: func ~atIndex (index: Int) -> T {
		result := this _vector[index]
		this _vector copy(index + 1, index)
		this _count -= 1
		result
	}
	removeAt: func (index: Int) {
		this _vector copy(index + 1, index)
		this _count -= 1
	}
	clear: func {
		this _vector _free(0, this _count)
		this _count = 0
	}
	free: override func {
		this clear()
		this _vector free()
		super()
	}

	operator [] (index: Int) -> T {
		this _vector[index]
	}
	operator []= (index: Int, item: T) {
		this _vector[index] = item
	}
	sort: func (greaterThan: Func (T, T) -> Bool) {
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0 .. count - 1) {
				if (greaterThan(this[i], this[i + 1])) {
					inOrder = false
					tmp := this[i]
					this[i] = this[i + 1]
					this[i + 1] = tmp
				}
			}
		}
	}
	copy: func -> This<T> {
		result := This new(this _count)
		memcpy(result pointer, this pointer, this _count * T size)
		result _count = this _count
		result
	}
	apply: func (function: Func(T)) {
		for (i in 0 .. this count)
			function(this[i])
	}
	getFirstElements: func (number: Int) -> This<T> {
		result := This<T> new()
		number = number < count ? number : count
		for (i in 0 .. number)
			result add(this _vector[i])
		result
	}
	getElements: func (indices: This<Int>) -> This<T> {
		result := This<T> new()
		for (i in 0 .. indices count)
			result add(this[indices[i]])
		result
	}
	getSlice: func (range: Range) -> This<T> {
		result := This<T> new(range count)
		this getSliceInto(range, result&)
		result
	}
	getSliceInto: func (range: Range, buffer: This<T>@) {
		if (buffer _vector capacity < range count)
			buffer _vector resize(range count)
		buffer _count = range count
		source := (this pointer as Long + (range min * (T size))) as Pointer
		memcpy(buffer pointer, source, range count * (T size))
	}
}
