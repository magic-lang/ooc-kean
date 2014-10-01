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

VectorList: class <T> {
	_vector: Vector<T>
	_count: Int
	count := this _count
	init: func ~deafault {
		this init(32)
	}

	init: func ~heap (capacity: Int) {
		this init(HeapVector<T> new(capacity))
	}

	init: func (=_vector)
	add: func (item: T) {
		if (this _vector count <= this count) {
			this _vector resize(this _vector count + 8)
		}

		this _vector[this count] = item
		this count += 1
	}

	remove: func ~last -> T {
		this count -= 1
		this _vector[this count]
	}

	insert: func (index: Int, item: T) {
		if (this _vector count <= this count) {
			this _vector resize(this _vector count + 8)
		}

		this _vector copy(index,index+1)
		this _vector[index] = item
		this count += 1
	}

	remove: func (index: Int) -> T {
		tmp: T
		tmp = this _vector[index]
		this _vector copy(index+1,index)
		this count -= 1
		tmp
}

	operator [] (index: Int) -> T {
		this _vector[index]
	}
	operator []= (index: Int, item: T) {
		this _vector[index] = item
	}
}
