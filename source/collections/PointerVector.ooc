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
	_freeContent: Bool
	count ::= this _count

	init: /* protected */ func ~preallocated (=_backend, =_count, freeContent := false)
	init: /* protected */ func (=_count, freeContent := false) {
		this _freeContent = freeContent
	}
	free: override func {
		this _free(0, this count)
		memfree(this _backend)
		super()
	}
	_free: func ~range (start, end: Int) {
		if (this _freeContent) {
			for (i in start .. end) {
				old := this[i] as Object
				old free()
			}
		}
	}

	resize: virtual func (count: Int) {
		if (count < this count) {
			this _free(count, this count)
			this _count = count
		}
		else if (count > this count)
			this _count = count
	}
	move: func (sourceStart, targetStart: Int, count := 0) {
		if (count < 1)
			count = this count - sourceStart
		if (targetStart + count > this count)
			count = this count - targetStart
		memmove(this _backend + targetStart * Pointer size, this _backend + sourceStart * Pointer size, count * Pointer size)
	}
	copy: func ~within (sourceStart, targetStart: Int, count := 0) {
		this copy(sourceStart, this, targetStart, count)
	}
	copy: func (sourceStart: Int, target: This, targetStart: Int, count := 0) {
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

	operator [] (index: Int) -> Pointer { this _backend[index] }
	operator []= (index: Int, item: Pointer) { this _backend[index] = item }
}

PointerHeapVector: class extends PointerVector {
	init: func (count: Int) {
		super(count)
		this _allocate(count)
	}

	_allocate: func (count: Int) {
		this _backend = realloc(this _backend, count * Pointer size)
	}

	resize: override func (count: Int) {
		super()
		this _allocate(count)
	}
}

PointerStackVector: class extends PointerVector {
	init: func (data: Pointer*, count: Int) {
		super(data, count)
	}
	resize: override func (count: Int) {
		if (count > this count)
			count = this count
		super(count)
	}
}
