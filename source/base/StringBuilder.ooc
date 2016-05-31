/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

StringBuilder: class {
	_items: VectorList<String>
	init: func (capacity := 32) {
		this _items = VectorList<String> new(capacity, false)
	}
	free: override func {
		this _items free()
		super()
	}
	add: func (item: String) {
		this _items add(item)
	}
	insert: func (index: Int, item: String) {
		this _items insert(index, item)
	}
	join: func ~char (separator: Char) -> String {
		stringSeparator := separator toString()
		result := this join(stringSeparator)
		stringSeparator free()
		result
	}
	join: func ~string (separator: String) -> String {
		result: String
		if (this _items count > 0)
			result = this _items[0] clone()
		for (i in 1 .. this _items count)
			result = result & (separator + this _items[i])
		result
	}
}
