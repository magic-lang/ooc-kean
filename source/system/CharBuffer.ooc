/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

CharBuffer: class {
	size: Int
	capacity: Int = 0
	mallocAddr: Char*
	data: Char*

	init: func ~empty {
		init(1024)
	}

	init: func (capacity: Int) {
		this setCapacity(capacity)
	}

	init: func ~cStrWithLength (s: CString, length: Int, stringLiteral := false) {
		if (stringLiteral) {
			this data = s
			this size = length
			this mallocAddr = null
			this capacity = 0
		} else {
			this setLength(length)
			memcpy(this data, s, length)
		}
	}

	free: override func {
		if (this data != null && this capacity > 0)
			memfree(this mallocAddr)
		super()
	}

	_rshift: func -> SizeT { return this mallocAddr == null || this data == null ? 0 : (this data as SizeT - this mallocAddr as SizeT) as SizeT }

	/* used to overwrite the data/attributes of *this* with that of another This */
	setBuffer: func (newOne: This) {
		this data = newOne data
		this mallocAddr = newOne mallocAddr
		this capacity = newOne capacity
		this size = newOne size
	}

	length: func -> Int { this size }

	setCapacity: func (newCapacity: Int) {
		rshift := this _rshift()
		min := newCapacity + 1 + rshift

		if (min >= this capacity) {
			// allocate 20% + 10 bytes more than needed - just in case
			this capacity = (min * 120) / 100 + 10

			// align at 8 byte boundary for performance
			al := 8 - (this capacity % 8)
			if (al < 8) this capacity += al

			rs := rshift
			if (rs) this shiftLeft(rs)

			tmp := realloc(this mallocAddr, this capacity)
			if (!tmp) OutOfMemoryException new(This) throw()

			// if we were coming from a string literal, copy the original data as well (gc_realloc cant work on text segment)
			if (this size > 0 && this mallocAddr == null) {
				rs = 0
				if (tmp != null && this data != null)
					memcpy(tmp, this data, this size)
			}

			this mallocAddr = tmp
			this data = tmp
			if (rs) this shiftRight(rs)
		}
		// just to be sure to be always zero terminated
		if (this data)
			this data[newCapacity] = '\0'
	}

	/** sets capacity and size flag, and a zero termination */
	setLength: func (newLength: Int) {
		if (newLength != this size || newLength == 0) {
			if (newLength > this capacity || newLength == 0)
				this setCapacity(newLength)
			this size = newLength
			this data[this size] = '\0'
		}
	}

	// call only when you're sure that the data is zero terminated
	sizeFromData: func {
		this setLength(this data as CString length())
	}

	/*  shifts data pointer to the right count bytes if possible
		if count is bigger as possible shifts right maximum possible
		size and capacity is decreased accordingly  */
	// remark: can be called with negative value (done by leftShift)
	shiftRight: func (count: SSizeT) {
		if (count != 0 && this size != 0) {
			c := count
			rshift := this _rshift()
			if (c > this size) c = this size
			else if (c < 0 && c abs() > rshift) c = rshift *-1
			this data += c
			this size -= c
		}
	}

	/* shifts back count bytes, only possible if shifted right before */
	shiftLeft: func (count : SSizeT) {
		if (count != 0) this shiftRight (-count) // it can be so easy
	}

	clone: func -> This {
		this clone(this size)
	}

	clone: func ~withMinimum (minimumLength := this size) -> This {
		newCapa := minimumLength > this size ? minimumLength : this size
		copy := This new(newCapa)
		//"Cloning %s, new capa %zd, new size %zd" printfln(this data, newCapa, this size)
		copy size = this size
		memcpy(copy data, this data, this size)
		copy
	}

	substring: func ~tillEnd (start: Int) {
		this substring(start, this size)
	}

	substring: func (start, end: Int) {
		if (start < 0) start += this size + 1
		if (end < 0) end += this size + 1
		if (end != this size) this setLength(end)
		if (start > 0) this shiftRight(start)
	}

	times: func (count: Int) {
		origSize := this size
		this setLength(this size * count)
		for (i in 1 .. count) { // we start at 1, since the 0 entry is already there
			memcpy(this data + (i * origSize), this data, origSize)
		}
	}

	append: func ~buf (other: This) {
		if (other)
			this append~pointer(other data, other size)
	}

	append: func ~str (other: String) {
		if (other)
			this append~buf(other _buffer)
	}

	append: func ~pointer (other: CString, otherLength: Int) {
		This _checkLength(otherLength)
		origlen := this size
		this setLength(this size + otherLength)
		memcpy(this data + origlen, other, otherLength)
	}

	append: func ~cstr (other: CString) {
		if (other)
			this append~pointer(other, other length())
	}

	append: func ~bufLength (other: This, otherLength: Int) {
		this append(other data, otherLength)
	}

	append: func ~char (other: Char) {
		this append(other&, 1)
	}

	prepend: func ~buf (other: This) {
		this prepend(other data, other size)
	}

	prepend: func ~str (other: String) {
		this prepend(other _buffer)
	}

	prepend: func ~pointer (other: Char*, otherLength: Int) {
		This _checkLength(otherLength)
		if (this _rshift() < otherLength) {
			newthis := This new(this size + otherLength)
			memcpy(newthis data, other, otherLength)
			memcpy(newthis data + otherLength, this data, this size)
			newthis setLength(this size + otherLength)
			this setBuffer(newthis)
		} else {
			// seems we have enough room on the left
			this shiftLeft(otherLength)
			memcpy(this data , other, otherLength)
		}
	}

	prepend: func ~char (other: Char) {
		this prepend(other&, 1)
	}

	empty: func -> Bool {
		this size == 0
	}

	compare: func (other: This, start, length: Int) -> Bool {
		This _checkLength(length)
		if (this size < (start + length) || other size < length)
			return false
		for (i in 0 .. length)
			if (this data[start + i] != other[i])
				return false
		true
	}

	equals: final func (other: This) -> Bool {
		if ((this == null) || (other == null)) return false
		if (other size != this size) return false
		this compare(other, 0, this size)
	}

	startsWith: func (s: This) -> Bool {
		len := s length()
		if (this size < len) return false
		this compare(s, 0, len)
	}

	startsWith: func ~char (c: Char) -> Bool {
		(this size > 0) && (this data[0] == c)
	}

	endsWith: func (s: This) -> Bool {
		len := s size
		if (this size < len) return false
		this compare(s, this size - len, len)
	}

	endsWith: func ~char (c: Char) -> Bool {
		(this size > 0) && this data[this size-1] == c
	}

	find: func ~char (what: Char, offset: Int, searchCaseSensitive := true) -> Int {
		this find (what&, 1, offset, searchCaseSensitive)
	}

	find: func (what: This, offset: Int, searchCaseSensitive := true) -> Int {
		this find~pointer(what data, what size, offset, searchCaseSensitive)
	}

	find: func ~pointer (what: Char*, whatSize: Int, offset: Int, searchCaseSensitive := true) -> Int {
		if (offset >= this size || offset < 0 || what == null || whatSize == 0) return -1

		maxpos: Int = this size - whatSize // need a signed type here
		if (maxpos < 0) return -1

		found: Bool

		for (sstart in offset .. (maxpos + 1)) {
			found = true
			for (j in 0 .. whatSize) {
				if (searchCaseSensitive) {
					if (this data[sstart + j] != what[j]) {
						found = false
						break
					}
				} else {
					if (this data[sstart + j] toUpper() != what[j] toUpper()) {
						found = false
						break
					}
				}
			}
			if (found) return sstart
		}
		-1
	}

	findAll: func ~withCase (what : This, searchCaseSensitive := true) -> VectorList<Int> {
		this findAll(what data, what size, searchCaseSensitive)
	}

	findAll: func ~pointer (what : Char*, whatSize: Int, searchCaseSensitive := true) -> VectorList<Int> {
		if (what == null || whatSize == 0) {
			return VectorList<Int> new(0)
		}
		result := VectorList<Int> new (this size / whatSize)
		offset := -whatSize
		while (((offset = this find(what, whatSize, offset + whatSize, searchCaseSensitive)) != -1)) result add (offset)
		result
	}

	replaceAll: func ~buf (what, whit: This, searchCaseSensitive := true) {
		findResults := this findAll(what, searchCaseSensitive)
		if (findResults == null || findResults count == 0) {
			return
		}

		newlen: Int = this size + (whit size * findResults count) - (what size * findResults count)
		result := This new(newlen)
		result setLength(newlen)

		sstart: Int = 0 // source (this) start pos
		rstart: Int = 0 // result start pos

		for (item in findResults) {
			sdist := item - sstart // bytes to copy
			memcpy(result data + rstart, this data + sstart, sdist)
			sstart += sdist
			rstart += sdist

			memcpy(result data + rstart, whit data, whit size)
			sstart += what size
			rstart += whit size
		}
		// copy remaining last piece of source
		sdist := this size - sstart
		memcpy(result data + rstart, this data + sstart, sdist + 1) // +1 to copy the trailing zero as well
		this setBuffer(result)
	}

	replaceAll: func ~char (oldie, kiddo: Char) {
		for (i in 0 .. this size) {
			if (this data[i] == oldie) this data[i] = kiddo
		}
	}

	map: func (f: Func (Char) -> Char) {
		for (i in 0 .. this size) {
			this data[i] = f(this data[i])
		}
	}

	toLower: func {
		for (i in 0 .. this size) {
			this data[i] = this data[i] toLower()
		}
	}

	toUpper: func {
		for (i in 0 .. this size) {
			this data[i] = this data[i] toUpper()
		}
	}

	toString: func -> String { String new(this) }

	indexOf: func ~char (c: Char, start: Int = 0) -> Int {
		for (i in start .. this size) {
			if ((this data + i)@ == c) return i
		}
		return -1
	}

	indexOf: func ~buf (s: This, start: Int = 0) -> Int {
		return this find(s, start, false)
	}

	contains: func ~char (c: Char) -> Bool { this indexOf(c) != -1 }

	contains: func ~buf (s: This) -> Bool { this indexOf(s) != -1 }

	trim: func ~pointer (s: Char*, sLength: Int) {
		this trimRight(s, sLength)
		this trimLeft(s, sLength)
	}

	trim: func ~buf (s: This) {
		this trim(s data, s size)
	}

	trim: func ~char (c: Char) {
		this trim(c&, 1)
	}

	trim: func ~whitespace {
		this trim(" \r\n\t" toCString(), 4)
	}

	trimLeft: func ~space {
		this trimLeft(' ')
	}

	trimLeft: func ~char (c: Char) {
		this trimLeft(c&, 1)
	}

	trimLeft: func ~buf (s: This) {
		this trimLeft(s data, s size)
	}

	trimLeft: func ~pointer (s: Char*, sLength: Int) {
		if (this size == 0 || sLength == 0) return
		start: Int = 0
		while (start < this size && (this data + start)@ containedIn(s, sLength)) start += 1
		if (start == 0) return
		this shiftRight(start)
	}

	trimRight: func ~space { this trimRight(' ') }

	trimRight: func ~char (c: Char) {
		this trimRight(c&, 1)
	}

	trimRight: func ~buf (s: This) {
		this trimRight(s data, s size)
	}

	trimRight: func ~pointer (s: Char*, sLength: Int) {
		end := this size
		while (end > 0 && this data[end - 1] containedIn(s, sLength)) {
			end -= 1
		}
		if (end != this size) this setLength(end)
	}

	reverse: func {
		result := this
		bytesLeft := this size

		i := 0
		while (bytesLeft > 1) {
			c := result data[i]
			result data[i] = result data[this size - 1 - i]
			result data[this size - 1 - i] = c
			bytesLeft -= 2
			i += 1
		}
	}

	count: func (what: Char) -> Int {
		result: Int = 0
		for (i in 0 .. this size) {
			if (this data[i] == what) result += 1
		}
		result
	}

	count: func ~buf (what: This) -> Int {
		this findAll(what) count
	}

	lastIndexOf: func (c: Char) -> Int {
		i: Int = this size - 1
		while (i >= 0) {
			if (this data[i] == c) return i
			i -= 1
		}
		return -1
	}

	print: func {
		fwrite(this data, 1, this size, stdout)
	}

	print: func ~withStream (stream: FStream) {
		fwrite(this data, 1, this size, stream)
	}

	println: func {
		this print(stdout); '\n' print(stdout)
	}

	println: func ~withStream (stream: FStream) {
		this print(stream); '\n' print(stream)
	}

	toInt: func -> Int { strtol(this data, null, 10) }
	toInt: func ~withBase (base: Int) -> Int { strtol(this data, null, base) }
	toLong: func -> Long { strtol(this data, null, 10) }
	toLong: func ~withBase (base: Long) -> Long { strtol(this data, null, base) }
	toLLong: func -> LLong { strtoll(this data, null, 10) }
	toLLong: func ~withBase (base: LLong) -> LLong { strtoll(this data, null, base) }
	toULong: func -> ULong { strtoul(this data, null, 10) }
	toULong: func ~withBase (base: ULong) -> ULong { strtoul(this data, null, base) }
	toFloat: func -> Float { strtof(this data, null) }
	toDouble: func -> Double { strtod(this data, null) }
	toLDouble: func -> LDouble {
		result: LDouble
		version (android) {
			result = strtod(this data, null)
		}
		version (!android) {
			result = strtold(this data, null)
		}
		result
	}

	get: final func (index: Int) -> Char {
		if (index < 0) index = this size + index
		if (index < 0 || index >= this size) OutOfBoundsException new(This, index, this size) throw()
		this data[index]
	}

	set: final func (index: Int, value: Char) {
		if (index < 0) index = this size + index
		if (index < 0 || index >= this size) OutOfBoundsException new(This, index, this size) throw()
		this data[index] = value
	}

	toCString: func -> CString { this data as CString }

	split: func ~withChar (c: Char, maxTokens: SSizeT) -> VectorList<This> {
		this split(c&, 1, maxTokens)
	}

	split: func ~withStringWithoutmaxTokens (s: This) -> VectorList<This> {
		this split(s data, s size, -1)
	}

	split: func ~withCharWithoutmaxTokens (c: Char) -> VectorList<This> {
		this split(c&, 1, -1)
	}

	split: func ~withBufWithEmpties (s: This, empties: Bool) -> VectorList<This> {
		this split(s data, s size, empties ? -1 : 0)
	}

	split: func ~withCharWithEmpties (c: Char, empties: Bool) -> VectorList<This> {
		this split(c&, 1, empties ? -1 : 0)
	}

	/**
	 * Split a buffer to form a list of tokens delimited by `delimiter`
	 *
	 * @param delimiter Buffer that separates tokens
	 * @param maxTokens Maximum number of tokens
	 *   - if positive, the last token will be the rest of the string, if any.
	 *   - if negative, the string will be fully split into tokens
	 *   - if zero, it will return all non-empty elements
	 */
	split: func ~buf (delimiter: This, maxTokens: SSizeT) -> VectorList<This> {
		this split(delimiter data, delimiter size, maxTokens)
	}

	split: func ~pointer (delimiter: Char*, delimiterLength: SizeT, maxTokens: SSizeT) -> VectorList<This> {
		findResults := this findAll(delimiter, delimiterLength, true)
		maxItems := ((maxTokens <= 0) || (maxTokens > findResults count + 1)) ? findResults count + 1 : maxTokens
		result := VectorList<This> new(maxItems, false)
		sstart: SizeT = 0 //source (this) start pos

		for (item in 0 .. findResults count) {
			if ((maxTokens > 0) && (result count == maxItems - 1)) break

			sdist := findResults[item] - sstart // bytes to copy
			if (maxTokens != 0 || sdist > 0) {
				b := This new ((this data + sstart) as CString, sdist)
				result add(b)
			}
			sstart += sdist + delimiterLength
		}

		if (result count < maxItems) {
			sdist := this size - sstart // bytes to copy
			b := This new((this data + sstart) as CString, sdist)
			result add(b)
		}

		findResults free()
		result
	}
	_checkLength: static func (len: Int) {
		if (len < 0)
			raise("Negative length passed: %d" format(len))
	}
}

operator == (buff1, buff2: CharBuffer) -> Bool { buff1 equals(buff2) }
operator != (buff1, buff2: CharBuffer) -> Bool { !buff1 equals(buff2) }
operator [] (buffer: CharBuffer, index: Int) -> Char { buffer get(index) }
operator []= (buffer: CharBuffer, index: Int, value: Char) { buffer set(index, value) }
operator [] (buffer: CharBuffer, range: Range) -> CharBuffer {
	b := buffer clone()
	b substring(range min, range max)
	b
}
operator * (buffer: CharBuffer, count: Int) -> CharBuffer {
	b := buffer clone(buffer size * count)
	b times(count)
	b
}
operator + (left, right: CharBuffer) -> CharBuffer {
	b := left clone(left size + right size)
	b append(right)
	b
}
