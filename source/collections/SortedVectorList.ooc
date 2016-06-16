/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections

SortedVectorList: class <T> extends VectorList<T> {
	_defaultComparator: Func (T*, T*) -> Bool

	init: func ~default (=_defaultComparator) { super() }
	init: func ~heap (capacity: Int, =_defaultComparator, freeContent := true) { super(capacity, freeContent) }

	add: override func (item: T) {
		super(item)
		this sort(this _defaultComparator)
	}
	append: override func (other: List<T>) {
		super(other)
		this sort(this _defaultComparator)
	}

	operator [] <T> (index: Int) -> T { this as VectorList<T> _vector[index] }
	operator []= (index: Int, item: T) { this _vector[index] = item }
}
