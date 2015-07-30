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
use ooc-collections

StringBuilder: class {
	_stringList := VectorList<String> new()

	count ::= this _stringList count

	init: func ~default
	init: func ~string (value: String) {
		this init()
		this _stringList add(value)
	}
	init: func ~this (orig: This) {
		this init()
		orig _stringList apply( func (value: String) { this _stringList add(value) })
	}
	copy: func -> This {
		This new(this)
	}

	add: func (value: String) {
		this _stringList add(value)
	}

	append: func (other: This) {
		for (i in 0..other count)
			this _stringList add(other[i])
	}
	prepend: func (other: This) {
		for (i in 0..other count)
			this _stringList insert(0, other[i])
	}

	toString: func -> String {
		result := ""
		for (i in 0..this _stringList count) {
			result += _stringList[i]
		}
		result
	}

	operator [] (index: Int) -> String {
		this _stringList[index]
	}
	/*operator + (other: This) -> This {
		This new(this) append(other)
	}*/
}
