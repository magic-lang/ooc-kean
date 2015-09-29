/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
use ooc-base
use ooc-collections

TextBuilder: class {
	_data := VectorList<Text> new(32, false)
	_count: Int
	count ::= this _count

	init: func ~default
	init: func ~vectorList (data: VectorList<Text>) {
		for (i in 0 .. data count)
			this append(data[i])
	}
	init: func ~text (value: Text) {
		this init()
		this append(value)
	}
	init: func ~cstring (value: CString, length: Int) {
		this init()
		this append(value, length)
	}
	init: func ~this (original: This) {
		this init(original toText())
	}
	free: func {
		for (i in 0 .. this count)
			this _data[i] free(Owner Callee)
		this _data free()
		super()
	}
	copy: func -> This {
		This new(this)
	}
	append: func ~char (c: Char) {
		this append(Text new(c&, 1, Owner Stack) copy())
	}
	append: func ~cstring (value: CString, length: Int) {
		this append(Text new(value, length))
	}
	append: func ~text (value: Text) {
		this _count += value count
		this _data add(value claim())
	}
	append: func (other: This) {
		for (i in 0 .. other count)
			this append(other _data[i] copy())
	}
	prepend: func ~char (c: Char) {
		this prepend(Text new(c&, 1, Owner Stack) copy())
	}
	prepend: func ~cstring (value: CString, length: Int) {
		this prepend(Text new(value, length))
	}
	prepend: func ~text (value: Text) {
		this _count += value count
		this _data insert(0, value claim())
	}
	prepend: func ~This (other: This) {
		this prepend(other toText())
	}
	toString: func -> String {
		this toText() toString()
	}
	toText: func -> Text {
		this join(Text empty)
	}
	join: func ~withChar (separator: Char) -> Text {
		this join(Text new(separator))
	}
	join: func ~withText (separator: Text) -> Text {
		length := separator count * (this _data count - 1) + this count
		result: TextBuffer
		if (length > 0) {
			result = TextBuffer new(length)
			offset := 0
			for (i in 0 .. this _data count) {
				this _data[i] copyTo(result slice(offset))
				offset += this _data[i] count
				if (separator count > 0 && i < this count - 1) {
					separator copyTo(result slice(offset))
					offset += separator count
				}
			}
		}
		else
			result = TextBuffer empty
		Text new(result)
	}
	println: func {
		this toString() println().free()
	}
	operator [] (index: Int) -> Char {
		i := index
		position := 0
		c := this _data[position] count // Needed c for some strange reason.
		while (c <= index) {
			index -= c
			++position
			c = this _data[position] count
		}
		this _data[position][index]
	}
	operator + (other: This) -> This {
		result := This new(this).append(other)
		result
	}
	operator + (value: Text) -> This {
		result := This new(this).append(value)
		result
	}
	operator == (other: This) -> Bool {
		result := this count == other count
		i := 0
		while (i < this count && (result &= this[i] == other[i]))
			++i
		result
	}
	operator == (string: String) -> Bool {
		this == Text new(string)
	}
	operator == (text: Text) -> Bool {
		t := text take()
		result := this count == t count
		i := 0
		while (i < this count && (result &= this[i] == t[i]))
			++i
		text free(Owner Callee)
		result
	}
}

operator == (left: String, right: TextBuilder) -> Bool { right == left }
operator == (left: Text, right: TextBuilder) -> Bool { right == left }
