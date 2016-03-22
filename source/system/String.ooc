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

	init: func ~withBuffer (=_buffer)
	init: func ~withCStr (s: CString) { init(s, s length()) }
	init: func ~withCStrAndLength (s: CString, length: Int) {
		this _buffer = CharBuffer new(s, length)
	}
	free: override func {
		if (this _buffer mallocAddr == 0)
			string_literal_free(this)
		this _buffer free()
		super()
	}
	length: func -> Int {
		this _buffer size
	}
	equals: final func (other: This) -> Bool {
		result := false
		if (this == null)
			result = (other == null)
		else if (other != null)
			result = this _buffer equals(other _buffer)
		result
	}
	clone: func -> This { This new(this _buffer clone()) }
	substring: func ~tillEnd (start: Int) -> This { substring(start, this size) }
	substring: func (start, end: Int) -> This {
		result := this _buffer clone()
		result substring(start, end)
		result toString()
	}
	times: func (count: Int) -> This {
		result := this _buffer clone(this size * count)
		result times(count)
		result toString()
	}
	append: func ~str (other: This) -> This {
		if (!other) return this
		result := this _buffer clone(this size + other size)
		result append (other _buffer)
		result toString()
	}
	append: func ~char (other: Char) -> This {
		result := this _buffer clone(this size + 1)
		result append(other)
		result toString()
	}
	append: func ~cStr (other: CString) -> This {
		l := other length()
		result := this _buffer clone(this size + l)
		result append(other, l)
		result toString()
	}
	prepend: func ~str (other: This) -> This {
		result := this _buffer clone()
		result prepend(other _buffer)
		result toString()
	}
	prepend: func ~char (other: Char) -> This {
		result := this _buffer clone()
		result prepend(other)
		result toString()
	}
	empty: func -> Bool { this _buffer empty() }
	startsWith: func (s: This) -> Bool { this _buffer startsWith (s _buffer) }
	startsWith: func ~char (c: Char) -> Bool { this _buffer startsWith(c) }
	endsWith: func (s: This) -> Bool { this _buffer endsWith (s _buffer) }
	endsWith: func ~char (c: Char) -> Bool { this _buffer endsWith(c) }
	find: func (what: This, offset: Int, searchCaseSensitive := true) -> Int {
		this _buffer find(what _buffer, offset, searchCaseSensitive)
	}
	findAll: func (what: This, searchCaseSensitive := true) -> VectorList <Int> {
		this _buffer findAll(what _buffer, searchCaseSensitive)
	}
	replaceAll: func ~str (what, with: This, searchCaseSensitive := true) -> This {
		result := this _buffer clone()
		result replaceAll (what _buffer, with _buffer, searchCaseSensitive)
		result toString()
	}
	replaceAll: func ~char (oldie, kiddo: Char) -> This {
		(this _buffer clone()) replaceAll~char(oldie, kiddo) . toString()
	}
	map: func (f: Func (Char) -> Char) -> This {
		(this _buffer clone()) map(f). toString()
	}
	_bufVectorListToStrVectorList: func (x: VectorList<CharBuffer>) -> VectorList<This> {
		result := VectorList<This> new(x count)
		for (i in 0 .. x count) result add (x[i] toString())
		result
	}
	toLower: func -> This {
		(this _buffer clone()) toLower(). toString()
	}
	toUpper: func -> This {
		(this _buffer clone()) toUpper(). toString()
	}
	capitalize: func -> This {
		match (this size) {
			case 0 => this
			case 1 => toUpper()
			case =>
				this[0 .. 1] toUpper() + this[1 .. -1]
		}
	}
	indexOf: func ~char (c: Char, start: Int = 0) -> Int { this _buffer indexOf(c, start) }
	indexOf: func ~string (s: This, start: Int = 0) -> Int { this _buffer indexOf(s _buffer, start) }
	contains: func ~char (c: Char) -> Bool { this _buffer contains(c) }
	contains: func ~string (s: This) -> Bool { this _buffer contains(s _buffer) }
	trim: func ~pointer (s: Char*, sLength: Int) -> This {
		result := this _buffer clone()
		result trim~pointer(s, sLength)
		result toString()
	}
	trim: func ~string (s : This) -> This {
		result := this _buffer clone()
		result trim~buf(s _buffer)
		result toString()
	}
	trim: func ~char (c: Char) -> This {
		result := this _buffer clone()
		result trim~char(c)
		result toString()
	}
	trim: func ~whitespace -> This {
		result := this _buffer clone()
		result trim~whitespace()
		result toString()
	}
	trimLeft: func ~space -> This {
		result := this _buffer clone()
		result trimLeft~space()
		result toString()
	}
	trimLeft: func ~char (c: Char) -> This {
		result := this _buffer clone()
		result trimLeft~char(c)
		result toString()
	}
	trimLeft: func ~string (s: This) -> This {
		result := this _buffer clone()
		result trimLeft~buf(s _buffer)
		result toString()
	}
	trimLeft: func ~pointer (s: Char*, sLength: Int) -> This {
		result := this _buffer clone()
		result trimLeft~pointer(s, sLength)
		result toString()
	}
	trimRight: func ~space -> This {
		result := this _buffer clone()
		result trimRight~space()
		result toString()
	}
	trimRight: func ~char (c: Char) -> This {
		result := this _buffer clone()
		result trimRight~char(c)
		result toString()
	}
	trimRight: func ~string (s: This) -> This {
		result := this _buffer clone()
		result trimRight~buf(s _buffer)
		result toString()
	}
	trimRight: func ~pointer (s: Char*, sLength: Int) -> This {
		result := this _buffer clone()
		result trimRight~pointer(s, sLength)
		result toString()
	}
	reverse: func -> This {
		result := this _buffer clone()
		result reverse()
		result toString()
	}
	count: func (what: Char) -> Int { this _buffer count (what) }
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

		new(copy)
	}
	toCString: func -> CString { this _buffer data as CString }
	split: func ~withChar (c: Char, maxTokens: SSizeT) -> VectorList<This> {
		_bufVectorListToStrVectorList(this _buffer split(c, maxTokens))
	}
	split: func ~withStringWithoutmaxTokens (s: This) -> VectorList<This> {
		_bufVectorListToStrVectorList(this _buffer split(s _buffer, -1))
	}
	split: func ~withCharWithoutmaxTokens (c: Char) -> VectorList<This> {
		bufferSplit := this _buffer split(c)
		result := _bufVectorListToStrVectorList(bufferSplit)
		bufferSplit free()
		result
	}
	split: func ~withStringWithEmpties (s: This, empties: Bool) -> VectorList<This> {
		_bufVectorListToStrVectorList(this _buffer split(s _buffer, empties))
	}
	split: func ~withCharWithEmpties (c: Char, empties: Bool) -> VectorList<This> {
		_bufVectorListToStrVectorList(this _buffer split(c, empties))
	}
	/**
	 * Split a string to form a list of tokens delimited by `delimiter`
	 *
	 * @param delimiter String that separates tokens
	 * @param maxTokens Maximum number of tokens
	 *   - if positive, the last token will be the rest of the string, if any.
	 *   - if negative, the string will be fully split into tokens
	 *   - if zero, it will return all non-empty elements
	 */
	split: func ~str (delimiter: This, maxTokens: SSizeT) -> VectorList<This> {
		_bufVectorListToStrVectorList(this _buffer split(delimiter _buffer, maxTokens))
	}
	free: static func ~all {
		string_literal_free_all()
	}
}

operator + (left, right: String) -> String { left append(right) }
operator == (left, right: String) -> Bool { left equals(right) }
operator != (left, right: String) -> Bool { !left equals(right) }
operator + (left: String, right: Char) -> String { left append(right) }
operator + (left: String, right: CString) -> String { left append(right) }
operator + (left: String, right: LLong) -> String { left append(right toString()) }
operator + (left: String, right: LDouble) -> String { left append(right toString()) }
operator + (left: Char, right: String) -> String { right prepend(left) }
operator + (left: LLong, right: String) -> String { left toString() append(right) }
operator + (left: LDouble, right: String) -> String { left toString() append(right) }
operator * (string: String, count: Int) -> String { string times(count) }
operator [] (string: String, index: Int) -> Char { string _buffer [index] }
operator [] (string: String, range: Range) -> String { string substring(range min, range max) }
operator implicit as (s: String) -> Char* { s ? s toCString() : null }
operator implicit as (s: String) -> CString { s ? s toCString() : null }
operator implicit as (c: Char*) -> String { c ? String new(c, strlen(c)) : null }
operator implicit as (c: CString) -> String { c ? String new(c, strlen(c)) : null }
operator & (left, right: String) -> String {
	result := left + right
	left free()
	right free()
	result
}
operator >> (left, right: String) -> String {
	result := left + right
	left free()
	result
}
operator << (left, right: String) -> String {
	result := left + right
	right free()
	result
}
makeStringLiteral: func (str: CString, strLen: Int) -> String {
	result := String new(CharBuffer new(str, strLen, true))
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

GlobalCleanup register(|| String free~all(), true)
