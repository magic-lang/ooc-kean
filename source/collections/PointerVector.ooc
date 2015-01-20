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

PointerVector: abstract class {
	_backend: Pointer*
	_count: Int
	count ::= this _count
	_freeContent: Bool

	init: /* protected */ func ~preallocated (=_backend, =_count, freeContent := false) {}
	init: /* protected */ func (=_count, freeContent := false) {
		this _allocate(this _count)
		this _freeContent = freeContent
	}
	__destroy__: func {	this _free(0, this count) }
	_free: func ~range (start: Int, end: Int) {
		if (this _freeContent) {
			for (i in start..end) {
				old := this[i] as Object
				old free()
			}
		}
	}
	_allocate: abstract func (count: Int)

	resize: func (count: Int) {
		if (count < this count) {
			this _free(count, this count)
			this _count = count
		}
		else if (count > this count) {
			this _allocate(count)
			this _count = count
		}
	}
	move: func (sourceStart: Int, targetStart: Int, count := 0) {
		if (count < 1)
			count = this count - sourceStart
		if (targetStart + count > this count)
			count = this count - targetStart
		memmove(this _backend + targetStart * Pointer size, this _backend + sourceStart * Pointer size, count * Pointer size)
	}
	copy: func ~within (sourceStart: Int, targetStart: Int, count := 0) {
		this copy(sourceStart, this, targetStart, count)
	}
	copy: func (sourceStart: Int, target: PointerVector, targetStart: Int, count := 0) {
		if (count < 1)
			count = this count - sourceStart
		if (targetStart + count > target count)
			count = target count - targetStart

		source := this _backend + sourceStart * Pointer size
		destination := target _backend + targetStart * Pointer size
		length := count * Pointer size

		if ((source <= destination && destination <= source + length) || (destination <= source && source <= destination + length))
			memmove(destination, source, length)
		else
			memcpy(destination, source, length)
	}

	operator [] (index: Int) -> Pointer {
		this _backend[index]
	}

	operator []= (index: Int, item: Pointer) {
		this _backend[index] = item
	}
}


PointerHeapVector: class extends PointerVector {
	init: func(count: Int) {
		super(count)
	}

	_allocate: func(count: Int) {
		this _backend = gc_realloc(this _backend, count * Pointer size)
	}

	__destroy__: func {
		super()
		gc_free(this _backend)
	}
}

PointerStackVector: class extends PointerVector {
	init: func(data: Pointer*, count: Int) {
		super(data, count)
	}

	// TODO: Why does this function exist here?
	_allocate: func(count: Int)
	
	resize: func(count: Int) {
		if (count > this count)
			count = this count
		super(count)
	}
}
