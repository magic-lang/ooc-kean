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
	_stringList := VectorList<String> new(32, false)
	_freeList := VectorList<Bool> new()

	count ::= this _stringList count

	init: func ~default
	init: func ~string (value: String, free := true) {
		this init()
		this append(value, free)
	}
	init: func ~this (original: This) {
		this init()
		// This leaks memory
		//original _stringList apply( func (value: String) { this appendClone(value) })
		for (i in 0..original count) {
			this appendClone(original[i])
		}
	}
	free: func {
		for (i in 0.._freeList count)
			if(_freeList[i])
				_stringList[i] free()
		this _stringList free()
		this _freeList free()
		super()
	}
	copy: func -> This {
		This new(this)
	}
	append: func ~String (value: String, free := true) {
		this _stringList add(value)
		this _freeList add(free)
	}
	appendClone: func ~String (value: String) {
		this _stringList add(value clone())
		this _freeList add(true)
	}
	append: func ~This (other: This) {
		for (i in 0..other count)
			this appendClone(other[i])
	}
	prepend: func ~String (value: String, free := true) {
		this _stringList insert(0, value)
		this _freeList insert(0, free)
	}
	prependClone: func ~String (value: String) {
		this _stringList insert(0, value clone())
		this _freeList insert(0, true)
	}
	prepend: func ~This (other: This) {
		for (i in 0..other count)
			prependClone(other[other count -1 -i])
	}
	toString: func -> String {
		result := ""
		for (i in 0..this _stringList count)
			result = result >> this _stringList[i]
		result
	}
	println: func {
		this toString() println().free()
	}

	operator [] (index: Int) -> String {
		this _stringList[index]
	}
	operator []= (index: Int, value: String) {
		this _stringList[index] = value
	}
	operator + (other: This) -> This {
		result := This new(this).append(other)
		result
	}
	operator + (value: String) -> This {
		result := This new(this).append(value)
		result
	}
	operator == (other: This) -> Bool {
		leftString := this toString()
		rightString := other toString()
		result := leftString == rightString
		leftString free()
		rightString free()
		result
	}
	operator == (value: String) -> Bool {
		leftString := this toString()
		result := leftString == value
		leftString free()
		result
	}
}

operator + (value: String, stringBuilder: StringBuilder) -> StringBuilder {
	result := StringBuilder new(stringBuilder).prepend(value)
	result
}
operator == (value: String, stringBuilder: StringBuilder) -> Bool {
	stringBuilderString := stringBuilder toString()
	result := stringBuilderString == value
	stringBuilderString free()
	result
}
