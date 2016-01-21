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
use base
use collections

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
		this init()
		this append(original)
	}
	free: func {
		for (i in 0 .. this _data count)
			this _data[i] free(Owner Receiver)
		this _data free()
		super()
	}
	copy: func -> This { This new(this) }
	append: func ~char (c: Char) { this append(Text new(c)) }
	append: func ~cstring (value: CString, length: Int) { this append(Text new(value, length)) }
	append: func ~text (value: Text) {
		this _count += value take() count
		this _data add(value claim())
	}
	append: func (other: This) {
		for (i in 0 .. other _data count)
			this append(other _data[i] take() copy())
	}
	prepend: func ~char (c: Char) { this prepend(Text new(c)) }
	prepend: func ~cstring (value: CString, length: Int) { this prepend(Text new(value, length)) }
	prepend: func ~text (value: Text) {
		this _count += value take() count
		this _data insert(0, value claim())
	}
	prepend: func ~This (other: This) {
		c := other _data count
		for (i in 1 .. c + 1)
			this prepend(other _data[c - i] take() copy())
	}
	toString: func -> String { this toText() toString() }
	toText: func -> Text { this join(Text empty) }
	join: func ~withChar (separator: Char) -> Text { this join(Text new(separator)) }
	join: func ~withText (separator: Text) -> Text {
		s := separator take()
		length := s count * (this _data count - 1) + this count
		result: TextBuffer
		if (length > 0) {
			result = TextBuffer new(length) take()
			offset := 0
			for (i in 0 .. this _data count) {
				current := this _data[i] take()
				current copyTo(result slice(offset))
				offset += current count
				if (s count > 0 && i < this count - 1) {
					s copyTo(result slice(offset))
					offset += s count
				}
			}
		}
		else
			result = TextBuffer empty
		separator free(Owner Receiver)
		Text new(result give())
	}
	println: func { this toText() println() }

	operator + (other: This) -> This {
		this append(other)
		this
	}
	operator == (other: This) -> Bool {
		result := this count == other count
		i := 0
		while (i < this count && (result &= this[i] == other[i]))
			++i
		result
	}
	operator [] (index: Int) -> Char {
		position := 0
		c := this _data[position] take() count
		while (c <= index) {
			index -= c
			++position
			c = this _data[position] take() count
		}
		this _data[position] take()[index]
	}
	operator + (value: Text) -> This {
		this append(value)
		this
	}
	operator != (text: Text) -> Bool {
		!(this == text)
	}
	operator == (text: Text) -> Bool {
		t := text take()
		result := this count == t count
		i := 0
		while (i < this count && (result &= this[i] == t[i]))
			++i
		text free(Owner Receiver)
		result
	}
	operator == (string: String) -> Bool { this == Text new(string) }
}

operator == (left: String, right: TextBuilder) -> Bool { right == left }
operator != (left: String, right: TextBuilder) -> Bool { right != left }
operator == (left: Text, right: TextBuilder) -> Bool { right == left }
operator != (left: Text, right: TextBuilder) -> Bool { right != left }
