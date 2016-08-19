/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

StringBuilder: class {
	_items: VectorList<String>
	count ::= this _items count

	init: func (capacity := 32, ownsMemory := false) {
		this _items = VectorList<String> new(capacity, ownsMemory)
	}
	free: override func {
		this _items free()
		super()
	}
	add: func ~string (item: String) {
		this _items add(item)
	}
	add: func ~char (item: Char) {
		this _items add(item as String)
	}
	insert: func ~string (index: Int, item: String) {
		this _items insert(index, item)
	}
	insert: func ~char (index: Int, item: Char) {
		this _items insert(index, item as String)
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
	toString: func -> String { this join("") }
	operator [] (index: Int) -> String { this _items[index] }
	operator []= (index: Int, item: String) { this _items[index] = item }
}
