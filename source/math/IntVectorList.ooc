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
use base
use collections
import FloatVectorList

IntVectorList: class extends VectorList<Int> {
	init: func ~default {
		super()
	}
	init: func ~heap (capacity: Int) {
		super(capacity)
	}
	init: func ~fromVectorList (other: VectorList<Int>) {
		super(other _vector)
		this _count = other count
	}
	init: func ~withValue (capacity, value: Int) {
		super(capacity)
		for (i in 0 .. capacity)
			this add(value)
	}
	copy: func -> This {
		super() as This
	}
	contains: func (value: Int) -> Bool {
		result := false
		for (i in 0 .. this count)
			if (this _vector[i] == value) {
				result = true
				break
			}
		result
	}
	sort: func -> This {
		result := this copy()
		inOrder := false
		while (!inOrder) {
			inOrder = true
			for (i in 0 .. result count - 1)
				if (result[i] > result[i + 1]) {
					inOrder = false
					temporary := result[i]
					result[i] = result[i + 1]
					result[i + 1] = temporary
				}
		}
		result
	}
	// Returns a new, sorted list of unique elements, e.g. [1,2,1,5,2,7,6,7,7] -> [1,2,5,6,7]
	compress: func -> This {
		result := This new()
		if (this count > 0) {
			sortedList := this sort()
			result add(sortedList[0])
			for (i in 1 .. sortedList count)
				if (sortedList[i] != result[result count - 1])
					result add(sortedList[i])
			sortedList free()
		}
		result
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _count)
			result = result >> this[i] toString() >> "\n"
		result
	}
	toText: func -> Text {
		result: Text
		textBuilder := TextBuilder new()
		for (i in 0 .. this _count)
			textBuilder append(this[i] toText())
		result = textBuilder join(t"\n")
		result
	}

	operator [] <T> (index: Int) -> T {
		this as VectorList<Int> _vector[index]
	}
	operator []= (index: Int, item: Int) {
		this _vector[index] = item
	}
}
