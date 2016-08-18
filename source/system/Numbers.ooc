/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include stdint, stddef, float, ctype, sys/types, limits

INT8_MAX, INT8_MIN: extern static Long
INT16_MAX, INT16_MIN: extern static Long
INT32_MAX, INT32_MIN: extern static Long
INT64_MAX, INT64_MIN: extern static Long
UINT8_MAX: extern static Long
UINT16_MAX: extern static Long
UINT32_MAX: extern static Long
UINT64_MAX: extern static Long

LLong: cover from signed long long {
	toString: func -> String { "%lld" formatLLong(this as LLong) }
	toHexString: func -> String { "%llx" formatLLong(this as LLong) }
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

Long: cover from int64_t extends LLong {
	maximumValue ::= static INT64_MAX
	minimumValue ::= static INT64_MIN
}

Int: cover from int32_t extends LLong {
	maximumValue ::= static INT32_MAX
	minimumValue ::= static INT32_MIN
	toString: func -> String { "%d" formatInt(this) }
}

Short: cover from int16_t extends LLong {
	maximumValue ::= static INT16_MAX
	minimumValue ::= static INT16_MIN
}

SByte: cover from int8_t extends LLong {
	maximumValue ::= static INT8_MAX
	minimumValue ::= static INT8_MIN
}

ULLong: cover from unsigned long long extends LLong {
	toString: func -> String { "%llu" formatULLong(this as ULLong) }
	in: func (range: Range) -> Bool {
		this >= range min && this < range max
	}
}

ULong: cover from uint64_t extends ULLong {
	maximumValue ::= static UINT64_MAX
	minimumValue ::= static 0
}

UInt: cover from uint32_t extends ULLong {
	maximumValue ::= static UINT32_MAX
	minimumValue ::= static 0
	toString: func -> String { "%u" formatUInt(this) }
}

UShort: cover from uint16_t extends ULLong {
	maximumValue ::= static UINT16_MAX
	minimumValue ::= static 0
}

Byte: cover from uint8_t extends ULLong {
	maximumValue ::= static UINT8_MAX
	minimumValue ::= static 0
}

FLT_MIN, FLT_MAX: extern static Float
DBL_MIN, DBL_MAX, INFINITY, NAN: extern static Double
LDBL_MIN, LDBL_MAX: extern static LDouble
FLT_EPSILON: extern static Float
DBL_EPSILON: extern static Double

LDouble: cover from long double {
	isNumber ::= this == this
	toString: func (decimals := 2) -> String {
		formatting := ("%." & decimals toString() & "f")
		result := formatting formatDouble(this)
		formatting free()
		result
	}
	in: func (range: Range) -> Bool {
		this >= range min && this < range max
	}
}

Double: cover from double extends LDouble {
	isNumber ::= this == this
	toString: func (decimals := 2) -> String {
		formatting := ("%." & decimals toString() & "f")
		result := formatting formatDouble(this)
		formatting free()
		result
	}
}

Float: cover from float extends LDouble {
	isNumber ::= this == this
	toString: func (decimals := 2) -> String {
		formatting := ("%." & decimals toString() & "f")
		result := formatting formatFloat(this)
		formatting free()
		result
	}
}

SizeT: cover from size_t extends ULLong
SSizeT: cover from ssize_t extends LLong {
	toString: func -> String { "%u" formatSSizeT(this) }
}
PtrDiff: cover from ptrdiff_t extends SSizeT

Range: cover {
	min, max: Int
	init: func@ (=min, =max)
	reduce: func (f: Func (Int, Int) -> Int) -> Int {
		acc := f(this min, this min + 1)
		for (i in this min + 2 .. this max) acc = f(acc, i)
		acc
	}
	toString: func -> String {
		"%d, %d" format(this min, this max)
	}
}
