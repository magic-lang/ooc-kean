/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
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
