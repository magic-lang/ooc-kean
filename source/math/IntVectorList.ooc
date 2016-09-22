/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
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
	copy: override func -> This {
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
	toString: func (separator := "\n") -> String {
		result := this _count > 0 ? this[0] toString() : ""
		for (i in 1 .. this _count)
			result = (result >> separator) & this[i] toString()
		result
	}

	operator [] <T> (index: Int) -> T {
		this as VectorList<Int> _vector[index]
	}
	operator []= (index: Int, item: Int) {
		this _vector[index] = item
	}

	parse: static func (data, separator: String) -> This {
		items := data split(separator)
		result := This new(items count)
		for (i in 0 .. items count)
			result add(items[i] toInt())
		items free()
		result
	}
}
