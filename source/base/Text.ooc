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
import math

Text: cover {
	_buffer: TextBuffer
	count ::= this _buffer count
	isEmpty ::= this count == 0
	init: func@ ~empty {
		this init(TextBuffer new())
	}
	init: func@ (=_buffer)
	init: func@ ~fromStringLiteral (string: CString) {
		this init(string, strlen(string))
	}
	init: func@ ~fromString (string: String) {
		this init(string _buffer data, string length(), Owner Unknown)
	}
	init: func@ ~fromCharacter (character: Char) {
		this init(character&, 1, Owner Stack)
		this = this claim()
	}
	init: func@ ~fromData (string: CString, count: Int, owner := Owner Static) {
		this init(TextBuffer new(string, count, owner))
	}
	copy: func -> This { // call by value, creates copy of cover
		result := This new(this _buffer copy())
		this free(Owner Receiver)
		result
	}
	copyTo: func (buffer: TextBuffer) -> Int {
		this _buffer copyTo(buffer)
	}
	operator == (string: String) -> Bool {
		this == This new(string)
	}
	operator == (other: This) -> Bool {
		result := this _buffer == other _buffer
		this free(Owner Receiver)
		other free(Owner Receiver)
		result
	}
	operator != (other: String) -> Bool { !(this == other) }
	operator != (other: This) -> Bool { !(this == other) }
	beginsWith: func (other: This) -> Bool {
		this slice(0, Int minimum~two(other count, this count)) == other
	}
	beginsWith: func ~string (other: String) -> Bool {
		this beginsWith(This new(other))
	}
	beginsWith: func ~character (character: Char) -> Bool {
		result := (this count > 0) && (this _buffer[0] == character)
		this free(Owner Receiver)
		result
	}
	endsWith: func (other: This) -> Bool {
		this slice(Int maximum~two(0, this count - other count), Int minimum~two(other count, this count)) == other
	}
	endsWith: func ~string (other: String) -> Bool {
		this endsWith(This new(other))
	}
	endsWith: func ~character (character: Char) -> Bool {
		result := (this count > 0) && (this _buffer[this count - 1] == character)
		this free(Owner Receiver)
		result
	}
	find: func ~character (character: Char, start := 0) -> Int {
		result := -1
		t := this take()
		for (i in start .. t count)
			if (t[i] == character) {
				result = i
				break
			}
		this free(Owner Receiver)
		result
	}
	find: func ~text (needle: This, start := 0) -> Int {
		result := -1
		t := this take()
		n := needle take()
		for (i in start .. t count - n count + 1)
			if (t slice(i, n count) == n) {
				result = i
				break
			}
		this free(Owner Receiver)
		needle free(Owner Receiver)
		result
	}
	find: func ~string (string: String, start := 0) -> Int {
		this find(This new(string), start)
	}
	operator [] (index: Int) -> Char {
		result := this _buffer[index]
		this free(Owner Receiver)
		result
	}
	operator [] (range: Range) -> This {
		this slice(range min, range count)
	}
	take: func -> This { // call by value -> modifies copy of cover
		this _buffer = this _buffer take()
		this
	}
	give: func -> This { // call by value -> modifies copy of cover
		this _buffer = this _buffer give()
		this
	}
	claim: func -> This { // call by value -> modifies copy of cover
		this _buffer = this _buffer claim()
		this
	}
	free: func@ -> Bool {
		this _buffer free()
	}
	free: func@ ~withCriteria (criteria: Owner) -> Bool {
		this _buffer free(criteria)
	}
	slice: func (start: Int, distance := INT_MAX) -> This {
		result := This new(this _buffer slice(start, distance == INT_MAX ? this count - start : distance))
		if (this _buffer owner == Owner Receiver)
			result = result copy() // TODO: Could we be smarter here?
		this free(Owner Receiver)
		result
	}
	split: func ~character (separator: Char) -> VectorList<This> {
		this split(This new(separator))
	}
	split: func ~string (separator: String) -> VectorList<This> {
		this split(This new(separator))
	}
	split: func ~text (separator: This) -> VectorList<This> {
		t := this take()
		s := separator take()
		result := VectorList<This> new()
		start := 0
		while (start <= t count) {
			next := t find(s, start)
			if (next < 0)
				next = t count + 1
			p := t[start .. next - 1]
			result add(p)
			start = next + s count
		}
		this free(Owner Receiver)
		separator free(Owner Receiver)
		result
	}
	trim: func -> This {
		leftPosition := 0
		rightPosition := this count - 1
		while (leftPosition < this count && this _buffer[leftPosition] whitespace?())
			++leftPosition
		while (rightPosition > leftPosition && this _buffer[rightPosition] whitespace?())
			--rightPosition
		this slice(leftPosition, rightPosition - leftPosition + 1)
	}
	toString: func -> String {
		result := String new(this _buffer raw, this count)
		this free(Owner Receiver)
		result
	}
	toInt: func -> Int {
		result := this toLLong() as Int
		this free(Owner Receiver)
		result
	}
	toLong: func -> Long {
		result := this toLLong() as Long
		this free(Owner Receiver)
		result
	}
	toLLong: func -> LLong {
		result := this toLLong~inBase(this _detectNumericBase())
		this free(Owner Receiver)
		result
	}
	toInt: func ~inBase (base: Int) -> Int {
		result := this toLLong~inBase(base) as Int
		this free(Owner Receiver)
		result
	}
	toLong: func ~inBase (base: Int) -> LLong {
		result := this toLLong~inBase(base) as Long
		this free(Owner Receiver)
		result
	}
	toLLong: func ~inBase (base: Int) -> LLong {
		t := this take() trim()
		result := t isEmpty ? 0 : (t[0] == '-' ? -1 * t slice(1, t count - 1) toULong(base) : t toULong(base) as LLong)
		this free(Owner Receiver)
		result
	}
	toULong: func -> ULong {
		this toULong~inBase(this _detectNumericBase())
	}
	toULong: func ~inBase (base: Int) -> ULong {
		t := this take() trim()
		result := 0 as ULong
		if (!t isEmpty) {
			lastValidIndex := -1
			start := 0
			if (base == 16 && t beginsWith(This new(c"0x", 2))) {
				start += 2
				lastValidIndex += 2
			}
			for (i in start .. t count) {
				if (!This _isNumeric(t[i], base))
					break
				++lastValidIndex
			}
			power := 1 as ULong
			while (lastValidIndex >= 0) {
				result += power * This _toInt(t[lastValidIndex], base)
				--lastValidIndex
				power *= base
			}
		}
		this free(Owner Receiver)
		result
	}
	toFloat: func -> Float {
		this toLDouble() as Float
	}
	toDouble: func -> Double {
		this toLDouble() as Double
	}
	toLDouble: func -> LDouble {
		t := this take() trim()
		result := 0.0 as LDouble
		if (!t isEmpty) {
			sign := 1
			start := 0
			if (t[0] == '-') {
				start = 1
				sign = -1
			}
			index := this count
			for (i in start .. t count) {
				if (!This _isNumeric(t[i], 10)) {
					index = i
					break
				}
			}
			result = t slice(start, index - start) toLLong~inBase(10)
			if (index > -1 && index < t count) {
				if (t[index] == '.') {
					power := 0.1
					for (i in index + 1 .. t count) {
						if (This _isNumeric(t[i], 10)) {
							result += power * This _toInt(t[i], 10)
							power /= 10
						} else {
							index = i
							break
						}
					}
				}
				if (t[index] == 'e' || t[index] == 'E') {
					exponent := t slice(index + 1, t count - index) toInt~inBase(10)
					result = result * pow(10, exponent)
				}
			}
			result *= sign
		}
		result
	}
	_detectNumericBase: func -> Int {
		result := 10
		if (this beginsWith(This new(c"0x", 2)))
			result = 16
		result
	}
	_isNumeric: static func (character: Char, base: Int) -> Bool {
		version(safe) {
			if (base < 2 || (base > 10 && base != 16))
				raise("Unsupported numeric base in Text")
		}
		lastValidDigit := base < 10 ? '0' + (base - 1) : '9'
		result := (character >= '0') && (character <= lastValidDigit)
		if (!result && base == 16)
			result = (character >= 'a' && character <= 'f') || (character >= 'A' && character <= 'F')
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
operator []= (left: TextBuffer, range: Range, right: Text) { right _buffer copyTo(left slice(range min, range count)) }
