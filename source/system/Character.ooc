/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdint

__LINE__: extern Int
__FILE__: extern CString
__FUNCTION__: extern CString

strrchr: extern func (Char*, Int) -> Char*
strcmp: extern func (Char*, Char*) -> Int
strncmp: extern func (Char*, Char*, Int) -> Int
strstr: extern func (Char*, Char*) -> Char*
strlen: extern func (Char*) -> Int
strtol: extern func (Char*, Pointer, Int) -> Long
strtoll: extern func (Char*, Pointer, Int) -> LLong
strtoul: extern func (Char*, Pointer, Int) -> ULong
strtof: extern func (Char*, Pointer) -> Float
strtod: extern func (Char*, Pointer) -> Double

version (!cygwin) {
	strtold: extern func (Char*, Pointer) -> LDouble
} else {
	strtold: func (str: Char*, p: Pointer) -> LDouble { strtod(str, p) as LDouble }
}

Char: cover from char {
	toLower: extern (tolower) func -> This
	toUpper: extern (toupper) func -> This
	alphaNumeric: func -> Bool { this alpha() || this digit() }
	alpha: func -> Bool { this lower() || this upper() }
	lower: func -> Bool { this >= 'a' && this <= 'z' }
	upper: func -> Bool { this >= 'A' && this <= 'Z' }
	digit: func -> Bool { this >= '0' && this <= '9' }
	octalDigit: func -> Bool { this >= '0' && this <= '7' }
	control: func -> Bool { (this >= 0 && this <= 31) || this == 127 }
	graph: func -> Bool { this printable() && this != ' ' }
	printable: func -> Bool { this >= 32 && this <= 126 }
	punctuation: func -> Bool { this printable() && !this alphaNumeric() && this != ' ' }
	whitespace: func -> Bool { this == ' ' || this == '\f' || this == '\n' ||this == '\r' || this == '\t' || this == '\v' }
	blank: func -> Bool { this == ' ' || this == '\t' }
	hexDigit: func -> Bool { this digit() || (this >= 'A' && this <= 'F') || (this >= 'a' && this <= 'f') }
	toString: func -> String { String new(this& as CString, 1) }
	print: func { fputc(this, stdout) }
	print: func ~withStream (stream: FStream) { fputc(this, stream) }
	println: func {
		fputc(this, stdout)
		fputc('\n', stdout)
	}
	println: func ~withStream (stream: FStream) {
		fputc(this, stream)
		fputc('\n', stream)
	}
	containedIn: func (s: String) -> Bool {
		this containedIn(s _buffer data, s size)
	}
	containedIn: func ~charWithLength (s: Char*, sLength: SizeT) -> Bool {
		result := false
		for (i in 0 .. sLength)
			if ((s + i)@ == this) {
				result = true
				break
			}
		result
	}
	toInt: func -> Int {
		result := -1
		if (this digit())
			result = (this - '0') as Int
		result
	}
}

operator as (value: Char) -> String { value toString() }
operator as (value: Char*) -> String { value ? value as CString toString() : null }
operator as (value: CString) -> String { value ? value toString() : null }

CString: cover from Char* {
	clone: func -> This {
		length := this length()
		copy := This new(length)
		memcpy(copy, this, length + 1)
		copy as This
	}
	equals: func (other: This) -> Bool {
		result := false
		if (other != null) {
			(length, otherLength) := (this length(), other length())
			if (length == otherLength) {
				result = true
				for (i in 0 .. length)
					if (this[i] != other[i]) {
						result = false
						break
					}
			}
		}
		result
	}
	toString: func -> String { (this == null) ? null as String : String new(this, this length()) }
	length: extern (strlen) func -> Int
	print: func { stdout write(this, 0, this length()) }
	println: func { stdout write(this, 0, this length()) . write('\n') }
	new: static func ~withLength (length: Int) -> This {
		result := calloc(1, length + 1) as Char*
		result[length] = '\0'
		result as This
	}
}

operator == (str1: CString, str2: CString) -> Bool { (str1 == null || str2 == null) ? false : str1 equals(str2) }

operator != (str1: CString, str2: CString) -> Bool { !(str1 == str2) }
