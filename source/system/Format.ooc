/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

InvalidFormatException: class extends Exception {
	init: func (msg: CString) { this message = "invalid format string! \"" + msg == null ? "" : msg toString() + "\"" }
}

InvalidTypeException: class extends Exception {
	init: func (T: Class) { this message = "invalid type %s passed to generic function!" format(T name) }
}

// Text Formatting
TF_ALTERNATE := 1 << 0
TF_ZEROPAD := 1 << 1
TF_LEFT := 1 << 2
TF_SPACE := 1 << 3
TF_EXP_SIGN := 1 << 4
TF_SMALL := 1 << 5
TF_PLUS := 1 << 6
TF_UNSIGNED := 1 << 7

FSInfoStruct: cover {
	precision: Int
	fieldwidth: Int
	flags: SizeT
	base: Int
	bytesProcessed: SizeT
	length: Int
}

__digits: String = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
__digitsSmall: String = "0123456789abcdefghijklmnopqrstuvwxyz"

argNext: func<T> (va: VarArgsIterator*, T: Class) -> T {
	if (!va@ hasNext())
		InvalidFormatException new(null) throw()
	va@ next(T)
}

m_printn: func <T> (res: CharBuffer, info: FSInfoStruct@, arg: T) {
	sign: Char = '\0'
	tmp: Char[36]
	digits := __digits
	size := info fieldwidth
	i := 0
	n: ULong
	signed_n: Long
	n = T size == 4 ? arg as UInt : arg as ULong
	signed_n = T size == 4 ? arg as Int : arg as Long
	// Preprocess the flags
	if (info flags & TF_ALTERNATE && info base == 16)
		res append('0') . append(info flags & TF_SMALL ? 'x' : 'X')
	if (info flags & TF_SMALL)
		digits = __digitsSmall
	if (!(info flags & TF_UNSIGNED) && signed_n < 0)
		(sign, n) = ('-', -signed_n)
	else if (info flags & TF_EXP_SIGN)
		sign = '+'
	if (sign)
		size -= 1
	// Find the number in reverse
	if (n == 0) {
		tmp[i] = '0'
		i += 1
	} else
		while (n != 0) {
			tmp[i] = digits[n % info base]
			i += 1
			n /= info base
		}
	// Pad the number with zeros or spaces
	if (!(info flags & TF_LEFT))
		while (size > i) {
			size -= 1
			if (info flags & TF_ZEROPAD)
				res append('0')
			else
				res append(' ')
		}
		if (sign)
			res append(sign)
		// Write any zeros to satisfy the precision
		while (i < info precision) {
			info precision -= 1
			res append('0')
		}
	// Write the number
	while (i != 0) {
		i -= 1
		size -= 1
		res append(tmp[i])
	}
	// Left align the numbers
	if (info flags & TF_LEFT)
		while (size > 0) {
			size -= 1
			res append(' ')
		}
}

getCharPtrFromStringType: func <T> (s: T) -> Char* {
	res: Char* = null
	match (T) {
		case String => res = s as String ? s as String toCString() : null
		case CharBuffer => res = s as CharBuffer ? s as CharBuffer toCString() : null
		case CString => res = s as Char*
		case Pointer => res = s as Char*
		case =>
			if (T size == Pointer size)
				res = s as Char*
			else
				InvalidTypeException new(T) throw()
	}
	res
}

getSizeFromStringType: func<T> (s: T) -> SizeT {
	res: SizeT = 0
	match (T) {
		case String => res = s as String _buffer size
		case CharBuffer => res = s as CharBuffer size
		case CString => res = s as CString length()
		case Pointer => res = s as CString length()
		case => InvalidTypeException new(T) throw()
	}
	res
}

parseArg: func (res: CharBuffer, info: FSInfoStruct*, va: VarArgsIterator*, p: Char*) {
	info@ flags |= TF_UNSIGNED
	info@ base = 10
	mprintCall := true
	// Find the conversion
	match (p@) {
		case 'i' =>
			info@ flags &= ~TF_UNSIGNED
		case 'd' =>
			info@ flags &= ~TF_UNSIGNED
		case 'u' =>
		case 'o' =>
			info@ base = 8
		case 'x' =>
			info@ flags |= TF_SMALL
			info@ base = 16
		case 'X' =>
			info@ base = 16
		case 'p' =>
			info@ flags |= TF_ALTERNATE | TF_SMALL
			info@ base = 16
		case 'f' =>
			// Reconstruct the original format statement
			mprintCall = false
			tmp := CharBuffer new()
			tmp append('%')
			if (info@ flags & TF_ALTERNATE)
				tmp append('#')
			else if (info@ flags & TF_ZEROPAD)
				tmp append('0')
			else if (info@ flags & TF_LEFT)
				tmp append('-')
			else if (info@ flags & TF_SPACE)
				tmp append(' ')
			else if (info@ flags & TF_EXP_SIGN)
				tmp append('+')
			if (info@ fieldwidth != 0)
				tmp append(info@ fieldwidth toString())
			if (info@ precision >= 0) {
				tmp append('.')
				precisionString := info@ precision toString()
				tmp append(precisionString)
				precisionString free()
			}
			tmp append('f')
			T := va@ getNextType()
			toAppend: String
			tmpString := tmp toString()
			match T {
				case LDouble =>
					toAppend = tmpString cformat(argNext(va, LDouble) as LDouble)
				case Double =>
					toAppend = tmpString cformat(argNext(va, Double) as Double)
				case => // assume everything else is Float
					toAppend = tmpString cformat(argNext(va, Float) as Float)
			}
			res append(toAppend)
			(toAppend, tmpString) free()
		case 'c' =>
			mprintCall = false
			i := 0
			if (!(info@ flags & TF_LEFT))
				while (i < info@ fieldwidth) {
					i += 1
					res append(' ')
				}
			res append(argNext(va, Char) as Char)
			while (i < info@ fieldwidth) {
				i += 1
				res append(' ')
			}
			case 's' =>
				mprintCall = false
				T := va@ getNextType()
				s: T = argNext(va, T)
				sval: Char* = getCharPtrFromStringType(s)
				if (sval) {
					// Change to -2 so that 0-1 doesn't cause the loop to keep going
					if (info@ precision == -1) info@ precision = -2
					while ((sval@) && (info@ precision > 0 || info@ precision <= -2)) {
						if (info@ precision > 0)
							info@ precision -= 1
						res append(sval@)
						sval += 1
					}
				} else
					res append("(nil)")
		case '%' =>
			res append('%')
			mprintCall = false
		case =>
			mprintCall = false
	}
	if (mprintCall) {
		T := va@ getNextType()
		m_printn(res, info, argNext(va, T))
	}
}

parseArgOne: func <T> (res: CharBuffer, info: FSInfoStruct*, va: T, p: Char*) {
	info@ flags |= TF_UNSIGNED
	info@ base = 10
	mprintCall := true
	// Find the conversion
	match (p@) {
		case 'i' =>
			info@ flags &= ~TF_UNSIGNED
		case 'd' =>
			info@ flags &= ~TF_UNSIGNED
		case 'u' =>
		case 'o' =>
			info@ base = 8
		case 'x' =>
			info@ flags |= TF_SMALL
			info@ base = 16
		case 'X' =>
			info@ base = 16
		case 'p' =>
			info@ flags |= TF_ALTERNATE | TF_SMALL
			info@ base = 16
		case 'f' =>
			// Reconstruct the original format statement
			mprintCall = false
			tmp := CharBuffer new()
			tmp append('%')
			if (info@ flags & TF_ALTERNATE)
				tmp append('#')
			else if (info@ flags & TF_ZEROPAD)
				tmp append('0')
			else if (info@ flags & TF_LEFT)
				tmp append('-')
			else if (info@ flags & TF_SPACE)
				tmp append(' ')
			else if (info@ flags & TF_EXP_SIGN)
				tmp append('+')
			if (info@ fieldwidth != 0) {
				fieldwidthString := info@ fieldwidth toString()
				tmp append(fieldwidthString)
				fieldwidthString free()
			}
			if (info@ precision >= 0) {
				precisionString := info@ precision toString()
				tmp append('.') . append(precisionString)
				precisionString free()
			}
			tmp append('f')
			tmpString := tmp toString()
			match T {
				case LDouble =>
					cString := tmpString cformat(va as LDouble)
					res append(cString)
					cString free()
				case Double =>
					cString := tmpString cformat(va as Double)
					res append(cString)
					cString free()
				case => // assume everything else is Float
					cString := tmpString cformat(va as Float)
					res append(cString)
					cString free()
				}
			tmpString free()
		case '%' =>
			res append('%')
			mprintCall = false
		case =>
			mprintCall = false
	}
	if (mprintCall)
		m_printn(res, info, va)
}

getEntityInfo: func (info: FSInfoStruct@, va: VarArgsIterator*, start: Char*, end: Pointer) {
	// Save original pointer and find any flags
	p := start
	info flags = 0
	while (p as Pointer < end) {
		if (p < end) p += 1
		else InvalidFormatException new(start) throw()
		match (p@) {
			case '#' => info flags |= TF_ALTERNATE
			case '0' => info flags |= TF_ZEROPAD
			case '-' => info flags |= TF_LEFT
			case ' ' => info flags |= TF_SPACE
			case '+' => info flags |= TF_EXP_SIGN
			case => break
		}
	}
	// Find the field width
	info fieldwidth = 0
	while (p@ digit()) {
		if (info fieldwidth > 0)
			info fieldwidth *= 10
		info fieldwidth += (p@ as Int - 0x30)
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
	}
	// Find the precision
	info precision = -1
	if (p@ == '.') {
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
		info precision = 0
		if (p@ == '*') {
			T := va@ getNextType()
			info precision = argNext(va, T) as Int
			if (p < end)
				p += 1
			else
				InvalidFormatException new(start) throw()
		}
		while (p@ digit()) {
			if (info precision > 0)
				info precision *= 10
			info precision += (p@ as Int - 0x30)
			if (p < end)
				p += 1
			else
				InvalidFormatException new(start) throw()
		}
	}
	// Find the length modifier
	info length = 0
	while (p@ == 'l' || p@ == 'h' || p@ == 'L') {
		info length += 1
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
	}
	info bytesProcessed = p as SizeT - start as SizeT
}

getEntityInfoOne: func <T> (info: FSInfoStruct@, va: T*, start: Char*, end: Pointer) {
	// Save original pointer and find any flags
	p := start
	info flags = 0
	while (p as Pointer < end) {
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
		match (p@) {
			case '#' => info flags |= TF_ALTERNATE
			case '0' => info flags |= TF_ZEROPAD
			case '-' => info flags |= TF_LEFT
			case ' ' => info flags |= TF_SPACE
			case '+' => info flags |= TF_EXP_SIGN
			case => break
		}
	}
	// Find the field width
	info fieldwidth = 0
	while (p@ digit()) {
		if (info fieldwidth > 0)
			info fieldwidth *= 10
		info fieldwidth += (p@ as Int - 0x30)
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
	}
	// Find the precision
	info precision = -1
	if (p@ == '.') {
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
		info precision = 0
		if (p@ == '*')
			if (p < end)
				p += 1
			else
				InvalidFormatException new(start) throw()
		while (p@ digit()) {
			if (info precision > 0)
				info precision *= 10
			info precision += (p@ as Int - 0x30)
			if (p < end)
				p += 1
			else
				InvalidFormatException new(start) throw()
		}
	}
	// Find the length modifier
	info length = 0
	while (p@ == 'l' || p@ == 'h' || p@ == 'L') {
		info length += 1
		if (p < end)
			p += 1
		else
			InvalidFormatException new(start) throw()
	}
	info bytesProcessed = p as SizeT - start as SizeT
}

format: func ~main <T> (fmt: T, args: ...) -> T {
	if (args count == 0)
		return fmt
	res := CharBuffer new(512)
	va := args iterator()
	ptr := getCharPtrFromStringType(fmt)
	end: Pointer = (ptr as SizeT + getSizeFromStringType(fmt) as SizeT) as Pointer
	while (ptr as Pointer < end) {
		match (ptr@) {
			case '%' => {
				if (va hasNext()) {
					info: FSInfoStruct
					getEntityInfo(info&, va&, ptr, end)
					ptr += info bytesProcessed
					parseArg(res, info&, va&, ptr)
				} else {
					ptr += 1
					if (ptr@ == '%')
						res append(ptr@)
					else
						res append('%') . append(ptr@)
				}
			}
			case => res append(ptr@)
		}
		ptr += 1
	}
	result: T
	match (T) {
		case String => result = res toString()
		case CharBuffer => result = res
		case => result = res toCString()
	}
	result
}

formatOne: func ~main <T> (fmt: String, arg: T) -> String {
	res := CharBuffer new(64)
	ptr: Char* = fmt toCString()
	end: Pointer = (ptr as SizeT + fmt _buffer size as SizeT) as Pointer
	reddit := false
	while (ptr as Pointer < end) {
		match (ptr@) {
			case '%' => {
				if (!reddit) {
					reddit = true
					info: FSInfoStruct
					getEntityInfoOne(info&, arg&, ptr, end)
					ptr += info bytesProcessed
					parseArgOne(res, info&, arg, ptr)
				} else {
					ptr += 1
					if (ptr@ == '%')
						res append(ptr@)
					else
						res append('%') . append(ptr@) // missing argument, display format string instead
				}
			}
			case => res append(ptr@)
		}
		ptr += 1
	}
	res toString()
}

extend CharBuffer {
	format: func (args: ...) { this setBuffer(format~main(this, args)) }
}

extend String {
	formatInt: func (arg: Int) -> This { formatOne~main(this, arg) }
	formatUInt: func (arg: UInt) -> This { formatOne~main(this, arg) }
	formatLLong: func (arg: LLong) -> This { formatOne~main(this, arg) }
	formatULLong: func (arg: ULLong) -> This { formatOne~main(this, arg) }
	formatFloat: func (arg: Float) -> This { formatOne~main(this, arg) }
	formatDouble: func (arg: Double) -> This { formatOne~main(this, arg) }
	formatSSizeT: func (arg: SSizeT) -> This { formatOne~main(this, arg) }
	formatLDouble: func (arg: LDouble) -> This { formatOne~main(this, arg) }
	format: func (args: ...) -> This { format~main(this, args) }
	printf: func (args: ...) { format~main(this, args) print() }
	printfln: func (args: ...) { format~main(this, args) println() }
}
