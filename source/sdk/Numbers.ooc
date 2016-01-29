/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdlib, stdint, stddef, float, ctype, sys/types
version(windows || apple) {
	include limits
}

SHRT_MIN, SHRT_MAX: extern static Short
USHRT_MAX: extern static UShort
INT_MIN, INT_MAX: extern static Int
UINT_MAX: extern static UInt
LONG_MIN, LONG_MAX: extern static Long
ULONG_MAX: extern static ULong
LLONG_MIN, LLONG_MAX: extern static LLong
ULLONG_MAX: extern static ULLong

LLong: cover from signed long long {
	toString: func -> String { "%lld" formatLLong(this as LLong) }
	toHexString: func -> String { "%llx" formatLLong(this as LLong) }
	toText: func -> Text {
		string := this toString()
		result := Text new(string) copy()
		string free()
		result
	}

	in: func (range: Range) -> Bool {
		this >= range min && this < range max
	}
	times: func (fn: Func) {
		for (i in 0 .. this)
			fn()
	}
	times: func ~withIndex (fn: Func(This)) {
		for (i in 0 .. this)
			fn(i)
	}
	abs: func -> This {
		this >= 0 ? this : this * -1
	}
}

Long: cover from int64_t extends LLong

Int: cover from int32_t extends LLong {
	toString: func -> String { "%d" formatInt(this) }
}

Short: cover from int16_t extends LLong

SByte: cover from int8_t extends LLong

ULLong: cover from unsigned long long extends LLong {
	toString: func -> String { "%llu" formatULLong(this as ULLong) }
	in: func (range: Range) -> Bool {
		this >= range min && this < range max
	}
}

ULong: cover from uint64_t extends ULLong

UInt: cover from uint32_t extends ULLong {
	toString: func -> String { "%u" formatUInt(this) }
	toText: func -> Text {
		string := this toString()
		result := Text new(string) copy()
		string free()
		result
	}
}

UShort: cover from uint16_t extends ULLong

Byte: cover from uint8_t extends ULLong

FLT_MIN, FLT_MAX: extern static Float
DBL_MIN, DBL_MAX, INFINITY, NAN: extern static Double
LDBL_MIN, LDBL_MAX: extern static LDouble

LDouble: cover from long double {
	isNumber ::= this == this
	toString: func -> String {
		"%.2f" formatDouble(this)
	}
	toText: func -> Text {
		string := this toString()
		result := Text new(string) copy()
		string free()
		result
	}
}

Double: cover from double extends LDouble {
	isNumber ::= this == this
	toString: func -> String {
		"%.2f" formatDouble(this)
	}
}

Float: cover from float extends LDouble {
	isNumber ::= this == this
	toString: func -> String {
		"%.2f" formatFloat(this)
	}
}

SizeT: cover from size_t extends ULLong
SSizeT: cover from ssize_t extends LLong {
	toString: func -> String { "%u" formatSSizeT(this) }
}

Range: cover {
	min, max: Int
	init: func@ (=min, =max)
	reduce: func (f: Func (Int, Int) -> Int) -> Int {
		acc := f(min, min + 1)
		for (i in min + 2 .. max) acc = f(acc, i)
		acc
	}
}
