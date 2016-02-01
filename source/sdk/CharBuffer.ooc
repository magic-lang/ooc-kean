/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

CharBuffer: class extends Iterable<Char> {
	size: Int
	capacity: Int = 0
	mallocAddr: Char*
	data: Char*

	init: func ~empty {
		init(1024)
	}

	init: func (capacity: Int) {
		setCapacity(capacity)
	}

	init: func ~cStrWithLength (s: CString, length: Int, stringLiteral := false) {
		if (stringLiteral) {
			data = s
			size = length
			mallocAddr = null
			capacity = 0
		} else {
			setLength(length)
			memcpy(data, s, length)
		}
	}

	free: override func {
		if (this data != null && this capacity > 0)
			memfree(this mallocAddr)
		super()
	}

	_rshift: func -> SizeT { return mallocAddr == null || data == null ? 0 : (data as SizeT - mallocAddr as SizeT) as SizeT }

	/* used to overwrite the data/attributes of *this* with that of another This */
	setBuffer: func (newOne: This) {
		data = newOne data
		mallocAddr = newOne mallocAddr
		capacity = newOne capacity
		size = newOne size
	}

	length: func -> Int { size }

	setCapacity: func (newCapacity: Int) {
		rshift := _rshift()
		min := newCapacity + 1 + rshift

		if (min >= capacity) {
			// allocate 20% + 10 bytes more than needed - just in case
			capacity = (min * 120) / 100 + 10

			// align at 8 byte boundary for performance
			al := 8 - (capacity % 8)
			if (al < 8) capacity += al

			rs := rshift
			if (rs) shiftLeft(rs)

			tmp := realloc(mallocAddr, capacity)
			if (!tmp) OutOfMemoryException new(This) throw()

			// if we were coming from a string literal, copy the original data as well (gc_realloc cant work on text segment)
			if (size > 0 && mallocAddr == null) {
				rs = 0
				if (tmp != null && data != null)
					memcpy(tmp, data, size)
			}

			mallocAddr = tmp
			data = tmp
			if (rs) shiftRight(rs)
		}
		// just to be sure to be always zero terminated
		if (data)
			data[newCapacity] = '\0'
	}

	/** sets capacity and size flag, and a zero termination */
	setLength: func (newLength: Int) {
		if (newLength != size || newLength == 0) {
			if (newLength > capacity || newLength == 0) {
				setCapacity(newLength)
			}
			size = newLength
			data[size] = '\0'
		}
	}

	// call only when you're sure that the data is zero terminated
	sizeFromData: func {
		setLength(data as CString length())
	}

	/*  shifts data pointer to the right count bytes if possible
		if count is bigger as possible shifts right maximum possible
		size and capacity is decreased accordingly  */
	// remark: can be called with negative value (done by leftShift)
	shiftRight: func (count: SSizeT) {
		if (count != 0 && size != 0) {
			c := count
			rshift := _rshift()
			if (c > size) c = size
			else if (c < 0 && c abs() > rshift) c = rshift *-1
			data += c
			size -= c
		}
	}

	/* shifts back count bytes, only possible if shifted right before */
	shiftLeft: func (count : SSizeT) {
		if (count != 0) shiftRight (-count) // it can be so easy
	}

	clone: func -> This {
		clone(size)
	}

	clone: func ~withMinimum (minimumLength := size) -> This {
		newCapa := minimumLength > size ? minimumLength : size
		copy := new(newCapa)
		//"Cloning %s, new capa %zd, new size %zd" printfln(data, newCapa, size)
		copy size = size
		memcpy(copy data, data, size)
		copy
	}

	substring: func ~tillEnd (start: Int) {
		substring(start, size)
	}

	substring: func (start, end: Int) {
		if (start < 0) start += size + 1
		if (end < 0) end += size + 1
		if (end != size) setLength(end)
		if (start > 0) shiftRight(start)
	}

	times: func (count: Int) {
		origSize := size
		setLength(size * count)
		for (i in 1 .. count) { // we start at 1, since the 0 entry is already there
			memcpy(data + (i * origSize), data, origSize)
		}
	}

	append: func ~buf (other: This) {
		if (other)
			append~pointer(other data, other size)
	}

	append: func ~str (other: String) {
		if (other)
			append~buf(other _buffer)
	}

	append: func ~pointer (other: CString, otherLength: Int) {
		_checkLength(otherLength)
		origlen := size
		setLength(size + otherLength)
		memcpy(data + origlen, other, otherLength)
	}

	append: func ~cstr (other: CString) {
		if (other)
			append~pointer(other, other length())
	}

	append: func ~bufLength (other: This, otherLength: Int) {
		append(other data, otherLength)
	}

	append: func ~char (other: Char) {
		append(other&, 1)
	}

	prepend: func ~buf (other: This) {
		prepend(other data, other size)
	}

	prepend: func ~str (other: String) {
		prepend(other _buffer)
	}

	prepend: func ~pointer (other: Char*, otherLength: Int) {
		_checkLength(otherLength)
		if (_rshift() < otherLength) {
			newthis := This new(size + otherLength)
			memcpy(newthis data, other, otherLength)
			memcpy(newthis data + otherLength, data, size)
			newthis setLength(size + otherLength)
			setBuffer(newthis)
		} else {
			// seems we have enough room on the left
			shiftLeft(otherLength)
			memcpy(data , other, otherLength)
		}
	}

	prepend: func ~char (other: Char) {
		prepend(other&, 1)
	}

	empty: func -> Bool {
		size == 0
	}

	compare: func (other: This, start, length: Int) -> Bool {
		_checkLength(length)
		if (size < (start + length) || other size < length) {
			return false
		}

		for (i in 0 .. length) {
			if (data[start + i] != other[i]) {
				return false
			}
		}
		true
	}

	equals: final func (other: This) -> Bool {
		if ((this == null) || (other == null)) return false
		if (other size != size) return false
		compare(other, 0, size)
	}

	startsWith: func (s: This) -> Bool {
		len := s length()
		if (size < len) return false
		compare(s, 0, len)
	}

	startsWith: func ~char (c: Char) -> Bool {
		(size > 0) && (data[0] == c)
	}

	endsWith: func (s: This) -> Bool {
		len := s size
		if (size < len) return false
		compare(s, size - len, len)
	}

	endsWith: func ~char (c: Char) -> Bool {
		(size > 0) && data[size-1] == c
	}

	find: func ~char (what: Char, offset: Int, searchCaseSensitive := true) -> Int {
		find (what&, 1, offset, searchCaseSensitive)
	}

	find: func (what: This, offset: Int, searchCaseSensitive := true) -> Int {
		find~pointer(what data, what size, offset, searchCaseSensitive)
	}

	find: func ~pointer (what: Char*, whatSize: Int, offset: Int, searchCaseSensitive := true) -> Int {
		if (offset >= size || offset < 0 || what == null || whatSize == 0) return -1

		maxpos : Int = size - whatSize // need a signed type here
		if (maxpos < 0) return -1

		found : Bool

		for (sstart in offset .. (maxpos + 1)) {
			found = true
			for (j in 0 .. whatSize) {
				if (searchCaseSensitive) {
					if (data[sstart + j] != what[j] ) {
						found = false
						break
					}
				} else {
					if (data[sstart + j] toUpper() != what[j] toUpper()) {
						found = false
						break
					}
				}
			}
			if (found) return sstart
		}
		-1
	}

	findAll: func ~withCase ( what : This, searchCaseSensitive := true) -> VectorList<Int> {
		findAll(what data, what size, searchCaseSensitive)
	}

	findAll: func ~pointer ( what : Char*, whatSize: Int, searchCaseSensitive := true) -> VectorList<Int> {
		if (what == null || whatSize == 0) {
			return VectorList<Int> new(0)
		}
		result := VectorList<Int> new (size / whatSize)
		offset : Int = (whatSize ) * -1
		while (((offset = find(what, whatSize, offset + whatSize, searchCaseSensitive)) != -1)) result add (offset)
		result
	}

	replaceAll: func ~buf (what, whit: This, searchCaseSensitive := true) {
		findResults := findAll(what, searchCaseSensitive)
		if (findResults == null || findResults count == 0) {
			return
		}

		newlen: Int = size + (whit size * findResults count) - (what size * findResults count)
		result := new(newlen)
		result setLength(newlen)

		sstart: Int = 0 // source (this) start pos
		rstart: Int = 0 // result start pos

		for (item in findResults) {
			sdist := item - sstart // bytes to copy
			memcpy(result data + rstart, data + sstart, sdist)
			sstart += sdist
			rstart += sdist

			memcpy(result data + rstart, whit data, whit size)
			sstart += what size
			rstart += whit size
		}
		// copy remaining last piece of source
		sdist := size - sstart
		memcpy(result data + rstart, data + sstart, sdist + 1) // +1 to copy the trailing zero as well
		setBuffer(result)
	}

	replaceAll: func ~char (oldie, kiddo: Char) {
		for (i in 0 .. size) {
			if (data[i] == oldie) data[i] = kiddo
		}
	}

	map: func (f: Func (Char) -> Char) {
		for (i in 0 .. size) {
			data[i] = f(data[i])
		}
	}

	toLower: func {
		for (i in 0 .. size) {
			data[i] = data[i] toLower()
		}
	}

	toUpper: func {
		for (i in 0 .. size) {
			data[i] = data[i] toUpper()
		}
	}

	toString: func -> String { String new(this) }

	indexOf: func ~char (c: Char, start: Int = 0) -> Int {
		for (i in start .. size) {
			if ((data + i)@ == c) return i
		}
		return -1
	}

	indexOf: func ~buf (s: This, start: Int = 0) -> Int {
		return find(s, start, false)
	}

	contains: func ~char (c: Char) -> Bool { indexOf(c) != -1 }

	contains: func ~buf (s: This) -> Bool { indexOf(s) != -1 }

	trim: func ~pointer (s: Char*, sLength: Int) {
		trimRight(s, sLength)
		trimLeft(s, sLength)
	}

	trim: func ~buf (s: This) {
		trim(s data, s size)
	}

	trim: func ~char (c: Char) {
		trim(c&, 1)
	}

	trim: func ~whitespace {
		trim(" \r\n\t" toCString(), 4)
	}

	trimLeft: func ~space {
		trimLeft(' ')
	}

	trimLeft: func ~char (c: Char) {
		trimLeft(c&, 1)
	}

	trimLeft: func ~buf (s: This) {
		trimLeft(s data, s size)
	}

	trimLeft: func ~pointer (s: Char*, sLength: Int) {
		if (size == 0 || sLength == 0) return
		start : Int = 0
		while (start < size && (data + start)@ containedIn(s, sLength) ) start += 1
		if (start == 0) return
		shiftRight( start )
	}

	trimRight: func ~space { trimRight(' ') }

	trimRight: func ~char (c: Char) {
		trimRight(c&, 1)
	}

	trimRight: func ~buf (s: This) {
		trimRight(s data, s size)
	}

	trimRight: func ~pointer (s: Char*, sLength: Int) {
		end := size
		while (end > 0 && data[end - 1] containedIn(s, sLength)) {
			end -= 1
		}
		if (end != size) setLength(end)
	}

	reverse: func {
		result := this
		bytesLeft := size

		i := 0
		while (bytesLeft > 1) {
			c := result data[i]
			result data[i] = result data[size - 1 - i]
			result data[size - 1 - i] = c
			bytesLeft -= 2
			i += 1
		}
	}

	count: func (what: Char) -> Int {
		result : Int = 0
		for (i in 0 .. size) {
			if (data[i] == what) result += 1
		}
		result
	}

	count: func ~buf (what: This) -> Int {
		findAll(what) count
	}

	lastIndexOf: func (c: Char) -> Int {
		i : Int = size - 1
		while (i >= 0) {
			if (data[i] == c) return i
			i -= 1
		}
		return -1
	}

	print: func {
		fwrite(data, 1, size, stdout)
	}

	print: func ~withStream (stream: FStream) {
		fwrite(data, 1, size, stream)
	}

	println: func {
		print(stdout); '\n' print(stdout)
	}

	println: func ~withStream (stream: FStream) {
		print(stream); '\n' print(stream)
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

	iterator: override func -> CharBufferIterator<Char> {
		CharBufferIterator<Char> new(this)
	}

	forward: func -> CharBufferIterator<Char> {
		iterator()
	}

	backward: func -> BackIterator<Char> {
		backIterator() reversed()
	}

	backIterator: func -> CharBufferIterator<Char> {
		iter := CharBufferIterator<Char> new(this)
		iter i = length()
		return iter
	}

	get: final func (index: Int) -> Char {
		if (index < 0) index = size + index
		if (index < 0 || index >= size) OutOfBoundsException new(This, index, size) throw()
		data[index]
	}

	set: final func (index: Int, value: Char) {
		if (index < 0) index = size + index
		if (index < 0 || index >= size) OutOfBoundsException new(This, index, size) throw()
		data[index] = value
	}

	toCString: func -> CString { data as CString }

	split: func ~withChar (c: Char, maxTokens: SSizeT) -> VectorList<This> {
		split(c&, 1, maxTokens)
	}

	split: func ~withStringWithoutmaxTokens (s: This) -> VectorList<This> {
		split(s data, s size, -1)
	}

	split: func ~withCharWithoutmaxTokens (c: Char) -> VectorList<This> {
		split(c&, 1, -1)
	}

	split: func ~withBufWithEmpties (s: This, empties: Bool) -> VectorList<This> {
		split(s data, s size, empties ? -1 : 0)
	}

	split: func ~withCharWithEmpties (c: Char, empties: Bool) -> VectorList<This> {
		split(c&, 1, empties ? -1 : 0)
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
		split(delimiter data, delimiter size, maxTokens)
	}

	split: func ~pointer (delimiter: Char*, delimiterLength: SizeT, maxTokens: SSizeT) -> VectorList<This> {
		findResults := findAll(delimiter, delimiterLength, true)
		maxItems := ((maxTokens <= 0) || (maxTokens > findResults count + 1)) ? findResults count + 1 : maxTokens
		result := VectorList<This> new(maxItems, false)
		sstart: SizeT = 0 //source (this) start pos

		for (item in 0 .. findResults count) {
			if ((maxTokens > 0) && (result count == maxItems - 1)) break

			sdist := findResults[item] - sstart // bytes to copy
			if (maxTokens != 0 || sdist > 0) {
				b := This new ((data + sstart) as CString, sdist)
				result add(b)
			}
			sstart += sdist + delimiterLength
		}

		if (result count < maxItems) {
			sdist := size - sstart // bytes to copy
			b := new((data + sstart) as CString, sdist)
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
