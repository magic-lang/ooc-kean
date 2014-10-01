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
	_count: Int
	count ::= this _count
	_freeContent: Bool

	init: /* protected */ func ~preallocated (=_backend, =_count, freeContent := false) {
	}
	init: /* protected */ func (=_count, freeContent := false) {
		this _allocate(this _count)
		this _freeContent = freeContent
	}
	__destroy__: func {
		this _free(0, this count)
	}
	_free: func ~range (start: Int, end: Int) {
		if (this _freeContent && T inheritsFrom?(Object)) {
			for (i in start..end) {
				old := this[i] as Object
				old free()
			}
		}
	}
	_allocate: abstract func (count: Int)

	resize: func (count: Int) {
		if (count < this count)
		{
			this _free(count, this count)
			this _count = count
		}
		else if (count > this count)
		{
			this _allocate(count)
			this _count = count
		}
	}
	move: func  (sourceStart: Int, targetStart: Int, count := 0) {
		if (count < 1)
			count = this count - sourceStart
		if (targetStart + count > this count)
			count = this count - targetStart
		memmove(this _backend + targetStart * T size, this _backend + sourceStart * T size, count * T size)
	}
	copy: func ~within (sourceStart: Int, targetStart: Int, count := 0) {
		this copy(sourceStart, this, targetStart, count)
	}
	copy: func (sourceStart: Int, target: Vector<T>, targetStart: Int, count := 0) {
		if (count < 1)
			count = this count - sourceStart
		if (targetStart + count > target count)
			count = target count - targetStart

		source := this _backend + sourceStart * T size
		destination := target _backend + targetStart * T size
		length := count * T size

		if (source <= destination && destination <= source + length || destination <= source && source <= destination + length)
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
	init: func(count: Int) {
		super(count)
	}
	_allocate: func(count: Int)   {
		this _backend = gc_realloc(this _backend, count * T size)
	}

	__destroy__: func {
		super()
		gc_free(this _backend)
	}
}

StackVector: class <T> extends Vector<T> {
	init: func(data: T*, count: Int) {
		super(data, count)
	}
	_allocate: func(count: Int) {
		this _backend
	}

	resize: func(count: Int) {
		if (count > this count)
			count = this count
		super(count)
	}
}
