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
use ooc-math
import math

Text: cover {
	_buffer: CString
	_count: Int
	_owner: Owner
	count ::= this _count
	isEmpty ::= this _count == 0
	raw ::= this _buffer
	init: func@ {
		this _buffer = null
		this _count = 0
		this _owner = Owner Unknown
	}
	init: func@ ~fromStringLiteral (string: CString) {
		this init(string, strlen(string))
	}
	init: func@ ~fromStringLiteralWithCount (string: CString, =_count) {
		this _buffer = string
		this _owner = Owner Literal
	}
	init: func@ ~fromString (string: String) {
		this init(string _buffer data, string length(), Owner Literal)
	}
	init: func@ ~fromData (=_buffer, =_count, =_owner)
	copy: func -> This {
		this slice(0, this count)
	}
	operator == (string: String) -> Bool {
		this == This new(string)
	}
	operator == (other: This) -> Bool {
		(this count == other count) && (memcmp(this raw, other raw, this count) == 0)
	}
	beginsWith: func (other: This) -> Bool {
		this slice(0, Int minimum~two(other count, this count)) == other
	}
	beginsWith: func ~string (other: String) -> Bool {
		this beginsWith(This new(other))
	}
	beginsWith: func ~char (c: Char) -> Bool {
		(this count > 0) && (this _buffer[0] == c)
	}
	endsWith: func (other: This) -> Bool {
		this slice(Int maximum~two(0, this count - other count), Int minimum~two(other count, this count)) == other
	}
	endsWith: func ~string (other: String) -> Bool {
		this endsWith(This new(other))
	}
	endsWith: func ~char (c: Char) -> Bool {
		(this count > 0) && (this _buffer[this count - 1] == c)
	}
	find: func ~char (c: Char, start := 0) -> Int {
		result := -1
		for (i in start .. this count)
			if (this[i] == c) {
				result = i
				break
			}
		result
	}
	find: func ~text (text: This, start := 0) -> Int {
		result := -1
		for (i in start .. this count - text count + 1)
			if (this slice(i, text count) == text) {
				result = i
				break
			}
		result
	}
	find: func ~string (string: String, start := 0) -> Int {
		this find(This new(string), start)
	}
	operator [] (index: Int) -> Char {
		this _buffer [index]
	}
	operator [] (range: Range) -> This {
		this slice(range min, range count)
	}
	take: func@ -> Bool {
		this _changeOwnership(Owner Caller)
	}
	give: func -> This {
		result := this copy()
		result _changeOwnership(Owner Callee)
		result
	}
	free: func@ -> Bool {
		result: Bool
		if ((result = (this _owner != Owner Literal && this _owner != Owner Stack && this _buffer != null))) {
			gc_free(this _buffer)
			this _buffer = null
			this _count = 0
		}
		result
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _owner == criteria && this free()
	}
	slice: func (start, distance: Int) -> This {
		count := abs(distance)
		if (start < 0)
			start = this count + start
		if (distance < 0)
			start -= count
		if (start < this count)
			This new(this _buffer + start, Int minimum~two(count, this count - start), Owner Literal)
		else
			This empty
	}
	split: func ~withChar (separator: Char) -> VectorList<This> {
		this split(This new(separator&, 1, Owner Stack))
	}
	split: func ~withString (separator: String) -> VectorList<This> {
		this split(This new(separator))
	}
	split: func ~withText (separator: This) -> VectorList<This> {
		result := VectorList<This> new()
		start := 0
		pos := this find(separator)
		while (pos != -1) {
			if (pos > start)
				result add(this slice(start, pos - start))
			start = pos + separator count
			pos = this find(separator, start)
		}
		if (start < this count && pos == -1)
			result add(this slice(start, this count - start))
		result
	}
	toString: func -> String {
		String new(this _buffer, this count)
	}
	toInt: func -> Int {
		this toLLong() as Int
	}
	toLong: func -> Long {
		this toLLong() as Long
	}
	toLLong: func -> LLong {
		this toLLong~inBase(this _detectNumericBase())
	}
	toInt: func ~inBase (base: Int) -> Int {
		this toLLong~inBase(base) as Int
	}
	toLong: func ~inBase (base: Int) -> LLong {
		this toLLong~inBase(base) as Long
	}
	toLLong: func ~inBase (base: Int) -> LLong {
		result := 0 as LLong
		if (this isEmpty == false) {
			if (this[0] == '-')
				result = -1 * this slice(1, this count - 1) toULong~inBase(base)
			else
				result = this toULong~inBase(base) as LLong
		}
		result
	}
	toULong: func -> ULong {
		this toULong~inBase(this _detectNumericBase())
	}
	toULong: func ~inBase (base: Int) -> ULong {
		result := 0 as ULong
		if (this isEmpty == false) {
			lastValidIndex := -1
			start := 0
			if (base == 16 && this beginsWith(This new(c"0x", 2))) {
				start += 2
				lastValidIndex += 2
			}
			for (i in start .. this count) {
				if (This _isNumeric(this[i], base))
					++lastValidIndex
				else
					break
			}
			power := 1 as ULong
			while (lastValidIndex >= 0) {
				result += power * This _toInt(this[lastValidIndex], base)
				--lastValidIndex
				power *= base
			}
		}
		result
	}
	toFloat: func -> Float {
		this toLDouble() as Float
	}
	toDouble: func -> Double {
		this toLDouble() as Double
	}
	toLDouble: func -> LDouble {
		result := 0.0 as LDouble
		if (!this isEmpty) {
			sign := 1
			start := 0
			if (this[0] == '-') {
				start = 1
				sign = -1
			}
			index := this count
			for (i in start .. this count) {
				if (!This _isNumeric(this[i], 10)) {
					index = i
					break
				}
			}
			result = this slice(start, index - start) toLLong~inBase(10)
			if (index > -1 && index < this count) {
				if (this[index] == '.') {
					power := 0.1
					for (i in index + 1 .. this count) {
						if (This _isNumeric(this[i], 10)) {
							result += power * This _toInt(this[i], 10)
							power /= 10
						} else {
							index = i
							break
						}
					}
				}
				if (this[index] == 'e' || this[index] == 'E') {
					exponent := this slice(index + 1, this count - index) toInt~inBase(10)
					result = result * pow(10, exponent)
				}
			}
			result *= sign
		}
		result
	}
	_allocateAndCopy: func@ (source: CString, size: Int) {
		this _count = size
		this _buffer = gc_malloc(size)
		memcpy(this _buffer, source, size)
	}
	_changeOwnership: func@ (target: Owner) -> Bool {
		result: Bool
		if ((result = (target != this _owner && target != Owner Stack && target != Owner Literal))) {
			if ((result = (this _owner == Owner Stack || this _owner == Owner Literal))) {
				source := this _buffer
				this _allocateAndCopy(source, this count)
			}
			this _owner = target
		}
		result
	}
	_detectNumericBase: func -> Int {
		result := 10
		if (this beginsWith(This new(c"0x", 2)))
			result = 16
		result
	}
	_isNumeric: static func (c: Char, base: Int) -> Bool {
		version(safe) {
			if (base < 2 || (base > 10 && base != 16))
				raise("Unsupported numeric base in Text")
		}
		lastValidDigit := base < 10 ? '0' + (base - 1) : '9'
		result := (c >= '0') && (c <= lastValidDigit)
		if (!result && base == 16)
			result = (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
		result
	}
	_toInt: static func (c: Char, base: Int) -> Int {
		result := 0
		if (_isNumeric(c, base)) {
			if (base != 16)
				result = (c - '0') as Int
			else {
				if (c >= '0' && c <= '9')
					result = (c - '0') as Int
				else if (c >= 'a' && c <= 'f')
					result = (c - 'a') as Int + 10
				else if (c >= 'A' && c <= 'F')
					result = (c - 'A') as Int + 10
			}
		}
		result
	}
	empty: static This { get { This new() } }
}
makeTextLiteral: func (str: CString, strLen: Int) -> Text {
	Text new(str, strLen)
}

operator == (left: String, right: Text) -> Bool { Text new(left) == right }
operator != (left: String, right: Text) -> Bool { !(left == right) }
operator != (left: Text, right: String) -> Bool { !(left == right) }
operator != (left: Text, right: Text) -> Bool { !(left == right) }
