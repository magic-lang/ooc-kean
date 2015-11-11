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
use ooc-collections
import math
import FloatVectorList

IntVectorList: class extends VectorList<Int> {
	init: func ~default {
		this super()
	}
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Int>) {
		this super(other _vector)
		this _count = other count
	}
	operator [] <T> (index: Int) -> T {
		this as VectorList<Int> _vector[index]
	}
	operator []= (index: Int, item: Int) {
		this _vector[index] = item
	}
	sort: func {
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0 .. this count - 1)
				if (this[i] > this[i + 1]) {
					inOrder = false
					tmp := this[i]
					this[i] = this[i + 1]
					this[i + 1] = tmp
				}
		}
	}
	compress: func -> This {
		result := This new()
		if (this count > 0) {
			this sort()
			result add(this[0])
			for (i in 1 .. this count)
				if (this[i] != result[result count - 1])
					result add(this[i])
		}
		result
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
}
