/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include ./string/string_literal

string_literal_new: extern func (String)
string_literal_free: extern func (String)
string_literal_free_all: extern func

String: class {
	// Avoid direct buffer access, as it breaks immutability.
	_buffer: CharBuffer
	size ::= this _buffer size
	_locked := false // Only global termination may unlock and free literals
	init: func ~withBuffer (=_buffer)
	init: func ~withCStr (s: CString) { init(s, s length()) }
	init: func ~withCStrAndLength (s: CString, length: Int) { this _buffer = CharBuffer new(s, length) }
	free: override func {
		if (!this _locked) {
			if (this _buffer mallocAddr == 0)
				string_literal_free(this)
			this _buffer free()
			super()
		}
	}
	_unlock: func { this _locked = false }
	equals: final func (other: This) -> Bool {
		result := false
		if (this == null)
			result = (other == null)
		else if (other != null)
			result = this _buffer equals(other _buffer)
		result
	}
	length: func -> Int { this _buffer size }
	clone: func -> This { This new(this _buffer clone()) }
	substring: func ~tillEnd (start: Int, freeOriginal := false) -> This { this substring(start, this size, freeOriginal) }
	substring: func (start, end: Int, freeOriginal := false) -> This {
		result := this _buffer clone() . substring(start, end)
		if (freeOriginal)
			this free()
		result toString()
	}
	times: func (count: Int, freeOriginal := false) -> This {
		result := this _buffer clone(this size * count) . times(count)
		if (freeOriginal)
			this free()
		result toString()
	}
	append: func ~str (other: This, freeOriginal := false) -> This {
		result := this
		if (other) {
			newBuffer := this _buffer clone(this size + other size) . append(other _buffer)
			result = newBuffer toString()
			if (freeOriginal)
				this free()
		}
		result
	}
	append: func ~char (other: Char, freeOriginal := false) -> This {
		result := this _buffer clone(this size + 1) . append(other)
		if (freeOriginal)
			this free()
		result toString()
	}
	append: func ~cStr (other: CString, freeOriginal := false) -> This {
		result := this _buffer clone(this size + other length()) . append(other, other length())
		if (freeOriginal)
			this free()
		result toString()
	}
	prepend: func ~str (other: This, freeOriginal := false) -> This {
		result := this
		if (other) {
			newBuffer := this _buffer clone() . prepend(other _buffer)
			result = newBuffer toString()
			if (freeOriginal)
				this free()
		}
		result
	}
	prepend: func ~char (other: Char, freeOriginal := false) -> This {
		result := this _buffer clone() . prepend(other)
		if (freeOriginal)
			this free()
		result toString()
	}
	empty: func -> Bool { this _buffer empty() }
	startsWith: func (s: This) -> Bool { this _buffer startsWith(s _buffer) }
	startsWith: func ~char (c: Char) -> Bool { this _buffer startsWith(c) }
	endsWith: func (s: This) -> Bool { this _buffer endsWith(s _buffer) }
	endsWith: func ~char (c: Char) -> Bool { this _buffer endsWith(c) }
	find: func (what: This, offset: Int = 0, searchCaseSensitive := true) -> Int { this _buffer find(what _buffer, offset, searchCaseSensitive) }
	findAll: func (what: This, searchCaseSensitive := true) -> VectorList <Int> { this _buffer findAll(what _buffer, searchCaseSensitive) }
	replaceAll: func ~str (what, with: This, searchCaseSensitive := true, freeOriginal := false) -> This {
		result := this _buffer clone() . replaceAll(what _buffer, with _buffer, searchCaseSensitive)
		if (freeOriginal)
			this free()
		result toString()
	}
	replaceAll: func ~char (what, with: Char, freeOriginal := false) -> This {
		result := this _buffer clone() . replaceAll~char(what, with)
		if (freeOriginal)
			this free()
		result toString()
	}
	map: func (f: Func (Char) -> Char, freeOriginal := false) -> This {
		result := this _buffer clone() . map(f)
		if (freeOriginal)
			this free()
		result toString()
	}
	toLower: func (freeOriginal := false) -> This {
		result := this _buffer clone() . toLower()
		if (freeOriginal)
			this free()
		result toString()
	}
	toUpper: func (freeOriginal := false) -> This {
		result := this _buffer clone() . toUpper()
		if (freeOriginal)
			this free()
		result toString()
	}
	indexOf: func ~char (c: Char, start: Int = 0) -> Int { this _buffer indexOf(c, start) }
	indexOf: func ~string (s: This, start: Int = 0) -> Int { this _buffer indexOf(s _buffer, start) }
	contains: func ~char (c: Char) -> Bool { this _buffer contains(c) }
	contains: func ~string (s: This) -> Bool { this _buffer contains(s _buffer) }
	trim: func ~pointer (s: Char*, sLength: Int) -> This { (this _buffer clone()) trim~pointer(s, sLength) . toString() }
	trim: func ~string (s : This) -> This { (this _buffer clone()) trim~buf(s _buffer) . toString() }
	trim: func ~char (c: Char) -> This { (this _buffer clone()) trim~char(c) . toString() }
	trim: func ~whitespace -> This { (this _buffer clone()) trim~whitespace() . toString() }
	trimLeft: func ~space -> This { (this _buffer clone()) trimLeft~space() . toString() }
	trimLeft: func ~char (c: Char) -> This { (this _buffer clone()) trimLeft~char(c) . toString() }
	trimLeft: func ~string (s: This) -> This { (this _buffer clone()) trimLeft~buf(s _buffer) . toString() }
	trimLeft: func ~pointer (s: Char*, sLength: Int) -> This { (this _buffer clone()) trimLeft~pointer(s, sLength) . toString() }
	trimRight: func ~space -> This { (this _buffer clone()) trimRight~space() . toString() }
	trimRight: func ~char (c: Char) -> This { (this _buffer clone()) trimRight~char(c) . toString() }
	trimRight: func ~string (s: This) -> This { (this _buffer clone()) trimRight~buf(s _buffer) . toString() }
	trimRight: func ~pointer (s: Char*, sLength: Int) -> This { (this _buffer clone()) trimRight~pointer(s, sLength) . toString() }
	reverse: func -> This { (this _buffer clone()) reverse() . toString() }
	count: func (what: Char) -> Int { this _buffer count(what) }
	count: func ~string (what: This) -> Int { this _buffer count~buf(what _buffer) }
	lastIndexOf: func (c: Char) -> Int { this _buffer lastIndexOf(c) }
	print: func { this _buffer print() }
	println: func { if (this _buffer != null) this _buffer println() }
	println: func ~withStream (stream: FStream) { if (this _buffer != null) this _buffer println(stream) }
	toInt: func -> Int { this _buffer toInt() }
	toInt: func ~withBase (base: Int) -> Int { this _buffer toInt~withBase(base) }
	toLong: func -> Long { this _buffer toLong() }
	toLong: func ~withBase (base: Long) -> Long { this _buffer toLong~withBase(base) }
	toLLong: func -> LLong { this _buffer toLLong() }
	toLLong: func ~withBase (base: LLong) -> LLong { this _buffer toLLong~withBase(base) }
	toULong: func -> ULong { this _buffer toULong() }
	toULong: func ~withBase (base: ULong) -> ULong { this _buffer toULong~withBase(base) }
	toFloat: func -> Float { this _buffer toFloat() }
	toDouble: func -> Double { this _buffer toDouble() }
	toLDouble: func -> LDouble { this _buffer toLDouble() }
	_bufVectorListToStrVectorList: func (x: VectorList<CharBuffer>) -> VectorList<This> {
		result := VectorList<This> new(x count)
		for (i in 0 .. x count)
			result add(x[i] toString())
		result
	}
	capitalize: func -> This {
		result := this clone()
		if (result size > 0)
			result _buffer[0] = result[0] toUpper()
		result
	}
	cformat: final func ~str (...) -> This {
		list: VaList
		va_start(list, this)
		numBytes := vsnprintf(null, 0, this _buffer data, list)
		va_end(list)
		copy := CharBuffer new(numBytes)
		copy size = numBytes
		va_start(list, this)
		vsnprintf(copy data, numBytes + 1, this _buffer data, list)
		va_end(list)
		This new(copy)
	}
	toCString: func -> CString { this _buffer data as CString }
	split: func ~withChar (c: Char, maxTokens: SSizeT) -> VectorList<This> {
		this _bufVectorListToStrVectorList(this _buffer split(c, maxTokens))
	}
	split: func ~withStringWithoutmaxTokens (s: This) -> VectorList<This> {
		bufferSplit := this _buffer split(s _buffer)
		result := this _bufVectorListToStrVectorList(bufferSplit)
		bufferSplit free()
		result
	}
	split: func ~withCharWithoutmaxTokens (c: Char) -> VectorList<This> {
		bufferSplit := this _buffer split(c)
		result := this _bufVectorListToStrVectorList(bufferSplit)
		bufferSplit free()
		result
	}
	split: func ~withStringWithEmpties (s: This, empties: Bool) -> VectorList<This> {
		this _bufVectorListToStrVectorList(this _buffer split(s _buffer, empties))
	}
	split: func ~withCharWithEmpties (c: Char, empties: Bool) -> VectorList<This> {
		this _bufVectorListToStrVectorList(this _buffer split(c, empties))
	}
	/**
	 * Split a string to form a list of tokens delimited by `delimiter`.
	 *   - if maxTokens > 0, the last token will be the rest of the string, if any.
	 *   - if maxTokens < 0, the string will be fully split into tokens
	 *   - if maxTokens = 0, it will return all non-empty elements
	 */
	split: func ~str (delimiter: This, maxTokens: SSizeT) -> VectorList<This> {
		this _bufVectorListToStrVectorList(this _buffer split(delimiter _buffer, maxTokens))
	}

	operator + (other: Float) -> This { this << other toString() }
	operator + (other: Double) -> This { this << other toString() }
	operator + (other: UInt) -> This { this << other toString() }
	operator + (other: Int) -> This { this << other toString() }

	operator & (other: Float) -> This { this & other toString() }
	operator & (other: Double) -> This { this & other toString() }
	operator & (other: UInt) -> This { this & other toString() }
	operator & (other: Int) -> This { this & other toString() }

	operator == (other: This) -> Bool { this equals(other) }
	operator != (other: This) -> Bool { !this equals(other) }
	operator [] (index: Int) -> Char { this _buffer[index] }
	operator [] (range: Range) -> This { this substring(range min, range max) }

	operator + (other: This) -> This { this append(other) }
	operator + (other: Char) -> This { this append(other, true) }
	operator + (other: CString) -> This { this append(other) }
	operator & (other: This) -> This {
		result := this + other
		(this, other) free()
		result
	}
	operator >> (other: This) -> This {
		result := this + other
		this free()
		result
	}
	operator << (other: This) -> This {
		result := this + other
		other free()
		result
	}

	free: static func ~all {
		string_literal_free_all()
	}
}

operator + (left: Char, right: String) -> String { right prepend(left) }
operator implicit as (s: String) -> Char* { s ? s toCString() : null }
operator implicit as (s: String) -> CString { s ? s toCString() : null }
operator implicit as (c: Char*) -> String { c ? String new(c, strlen(c)) : null }
operator implicit as (c: CString) -> String { c ? String new(c, strlen(c)) : null }

makeStringLiteral: func (str: CString, strLen: Int) -> String {
	result := String new(CharBuffer new(str, strLen, true))
	result _locked = true
	string_literal_new(result)
	result
}
strVectorListFromCString: func (argc: Int, argv: Char**) -> VectorList<String> {
	result := VectorList<String> new()
	argc times(|i| result add(argv[i] as CString toString()))
	result
}
strVectorListFromCString: func ~hack (argc: Int, argv: String*) -> VectorList<String> {
	strVectorListFromCString(argc, argv as Char**)
}
strArrayFromCString: func (argc: Int, argv: Char**) -> String[] {
	result := String[argc] new()
	argc times(|i| result[i] = (argv[i] as CString toString()))
	result
}
strArrayFromCString: func ~hack (argc: Int, argv: String*) -> String[] {
	strArrayFromCString(argc, argv as Char**)
}
cStringPtrToStringPtr: func (cstr: CString*, len: Int) -> String* {
	toRet: String* = calloc(len, Pointer size) // otherwise the pointers are stack-allocated
	for (i in 0 .. len)
		toRet[i] = makeStringLiteral(cstr[i], cstr[i] length())
	toRet
}

GlobalCleanup register(|| String free~all(), 10)
