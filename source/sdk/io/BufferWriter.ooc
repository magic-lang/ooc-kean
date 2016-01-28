/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/Writer

BufferWriter: class extends Writer {
	buffer: CharBuffer
	pos := 0L

	init: func { this init(CharBuffer new(1024)) }
	init: func ~withBuffer (=buffer)
	buffer: func -> CharBuffer { this buffer }
	close: override func
	_makeRoom: func (len: Long) {
		if (this buffer capacity < len)
			this buffer setCapacity(len * 2)
		if (this buffer size < len)
			this buffer size = len
	}
	write: override func ~chr (chr: Char) {
		_makeRoom(pos + 1)
		buffer data[pos] = chr
		this pos += 1
	}
	mark: func -> Long {
		this pos
	}
	seek: func (p: Long) {
		if (p < 0 || p > buffer size)
			Exception new("Seeking out of bounds! p = %d, size = %d" format(p, this buffer size)) throw()
		this pos = p
	}
	write: override func (chars: Char*, length: SizeT) -> SizeT {
		_makeRoom(this pos + length)
		memcpy(this buffer data + pos, chars, length)
		this pos += length
		length
	}
	// This version is mostly for internal usage (it is called by writef)
	vwritef: func (fmt: String, list: VaList) {
		list2: VaList
		va_copy(list2, list)
		length := vsnprintf(null, 0, fmt, list2)
		va_end(list2)

		_makeRoom(pos + length + 1)
		vsnprintf(this buffer data + pos, length + 1, fmt, list)
		pos += length
	}
}
