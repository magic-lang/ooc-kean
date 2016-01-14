import io/[Reader, Writer]

_Endianness: enum {
	little
	big
}

BinarySequenceWriter: class {
	writer: Writer
	endianness := ENDIANNESS

	init: func (=writer)
	_pushByte: func (byte: Byte) {
		writer write(byte as Char)
	}
	pushValue: func <T> (value: T) {
		size := T size
		if (endianness != ENDIANNESS)
			value = This reverseBytes(value)
		array := value& as Byte*
		for (i in 0 .. size)
			_pushByte(array[i])
	}

	s8: func (value: SByte) { pushValue(value) }
	s16: func (value: Short) { pushValue(value) }
	s32: func (value: Int) { pushValue(value) }
	s64: func (value: Long) { pushValue(value) }
	u8: func (value: Byte) { pushValue(value) }
	u16: func (value: UShort) { pushValue(value) }
	u32: func (value: UInt) { pushValue(value) }
	u64: func (value: ULong) { pushValue(value) }
	pad: func (bytes: SizeT) { for (_ in 0 .. bytes) s8(0) }
	float32: func (value: Float) { pushValue(value) }
	float64: func (value: Double) { pushValue(value) }

	/** push it, null-terminated. */
	cString: func (value: String) {
		for (chr in value)
			u8(chr as Byte)
		s8(0)
	}
	pascalString: func (value: String, lengthBytes: SizeT) {
		length := value length()
		match (lengthBytes) {
			case 1 => u8(length)
			case 2 => u16(length)
			case 3 => u32(length)
			case 4 => u64(length)
		}
		for (chr in value)
			u8(chr as Byte)
	}
	bytes: func (value: Byte*, length: SizeT) {
		for (i in 0 .. length)
			u8(value[i] as Byte)
	}
	bytes: func ~string (value: String) {
		for (i in 0 .. value length())
			u8(value[i] as Byte)
	}
	reverseBytes: static func <T> (value: T) -> T {
		array := value& as Byte*
		size := T size
		reversed: T
		reversedArray := reversed& as Byte*
		for (i in 0 .. size)
			reversedArray[size - i - 1] = array[i]
		reversed
	}
}

BinarySequenceReader: class {
	reader: Reader
	endianness := ENDIANNESS
	bytesRead: SizeT

	init: func (=reader) {
		bytesRead = 0
	}
	pullValue: func <T> (T: Class) -> T {
		size := T size
		bytesRead += size
		value: T
		array := value& as Byte*
		for (i in 0 .. size)
			array[i] = reader read() as Byte
		if (endianness != ENDIANNESS)
			value = reverseBytes(value)
		value
	}
	s8: func -> SByte { pullValue(SByte) }
	s16: func -> Short { pullValue(Short) }
	s32: func -> Int { pullValue(Int) }
	s64: func -> Long { pullValue(Long) }
	u8: func -> Byte { pullValue(Byte) }
	u16: func -> UShort { pullValue(UShort) }
	u32: func -> UInt { pullValue(UInt) }
	u64: func -> ULong { pullValue(ULong) }
	skip: func (bytes: UInt) {
		for (_ in 0 .. bytes)
			reader read()
	}
	float32: func -> Float { pullValue(Float) }
	float64: func -> Double { pullValue(Double) }

	/** pull it, null-terminated */
	cString: func -> String {
		buffer := CharBuffer new()
		while (true) {
			value := u8()
			if (value == 0)
				break
			buffer append(value as Char)
		}
		buffer toString()
	}
	pascalString: func (lengthBytes: SizeT) -> String {
		length := match (lengthBytes) {
			case 1 => u8()
			case 2 => u16()
			case 4 => u32()
		}
		s := CharBuffer new()
		for (i in 0 .. length) {
			s append(u8() as Char)
		}
		String new(s)
	}
	bytes: func (length: SizeT) -> Byte* {
		value := calloc(length, Byte size) as Byte*
		for (i in 0 .. length)
			value[i] = u8() as Byte
		value
	}
}

// calculate endianness
_i := 0x10f as UShort
ENDIANNESS := (_i& as Byte*)[0] == 0x0f ? _Endianness little : _Endianness big
