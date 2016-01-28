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

import PointerVector

PointerVectorList: class {
	_vector: PointerVector
	_count: Int
	count := this _count
	init: func ~default {
		this init(32)
	}

	init: func ~heap (capacity: Int) {
		this init(PointerHeapVector new(capacity))
	}

	init: func (=_vector)
	free: override func {
		for (i in 0 .. this count)
			memfree(this _vector[i])
		this _vector free()
		super()
	}
	add: func (item: Pointer) {
		if (this _vector count <= this count) {
			this _vector resize(this _vector count + 8)
		}

		this _vector[this count] = item
		this count += 1
	}

	remove: func ~last -> Pointer {
		this count -= 1
		this _vector[this count]
	}

	insert: func (index: Int, item: Pointer) {
		if (this _vector count <= this count) {
			this _vector resize(this _vector count + 8)
		}

		this _vector copy(index, index + 1)
		this _vector[index] = item
		this count += 1
	}

	remove: func (index: Int) -> Pointer {
		tmp := this _vector[index]
		this _vector copy(index + 1, index)
		this count -= 1
		tmp
	}

	operator [] (index: Int) -> Pointer { this _vector[index] }
	operator []= (index: Int, item: Pointer) { this _vector[index] = item }
}
