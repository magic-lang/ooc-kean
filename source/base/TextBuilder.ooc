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
	count ::= this _data count

	init: func ~default
	init: func ~vector (=_data)
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
		for (i in 0 .. original count)
			this append(original[i] copy())
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
	append: func ~cstring (value: CString, length: Int) {
		this append(Text new(value, length))
	}
	append: func ~text (value: Text) {
		this _data add(value)
	}
	append: func (other: This) {
		for (i in 0 .. other count)
			this append(other[i] copy())
	}
	prepend: func ~cstring (value: CString, length: Int) {
		this prepend(Text new(value, length))
	}
	prepend: func ~text (value: Text) {
		this _data insert(0, value)
	}
	prepend: func ~This (other: This) {
		for (i in 0 .. other count)
			prepend(other[other count -1 -i] copy())
	}
	toString: func -> String {
		result := ""
		for (i in 0 .. this _data count)
			result = result << this _data[i] toString()
		result
	}
	toText: func -> Text {
		this join(Text empty)
	}
	join: func ~withChar (separator: Char) -> Text {
		this join(Text new(separator&, 1, Owner Stack))
	}
	join: func ~withText (separator: Text) -> Text {
		totalLength := separator count * (this count - 1)
		buffer := null as CString
		for (i in 0 .. this count)
			totalLength += this[i] count
		if (totalLength > 0) {
			buffer = gc_malloc(totalLength)
			offset := 0
			for (i in 0 .. this count) {
				memcpy(buffer + offset, this[i] raw, this[i] count)
				offset += this[i] count
				if (separator count > 0 && i < this count - 1) {
					memcpy(buffer + offset, separator raw, separator count)
					offset += separator count
				}
			}
		}
		Text new(buffer, totalLength, Owner Caller)
	}
	println: func {
		this toString() println().free()
	}
	operator [] (index: Int) -> Text {
		this _data[index]
	}
	operator []= (index: Int, value: Text) {
		this _data[index] free(Owner Callee)
		this _data[index] = value
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
		first := this toText()
		second := other toText()
		result := first == second
		first free()
		second free()
		result
	}
	operator == (string: String) -> Bool {
		value := this toText()
		result := value == string
		value free()
		result
	}
	operator == (text: Text) -> Bool {
		value := this toText()
		result := value == text
		value free()
		result
	}
}

operator == (left: String, right: TextBuilder) -> Bool { right == left }
operator == (left: Text, right: TextBuilder) -> Bool { right == left }
