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
	mark: func -> Long { this pos }
	close: override func
	_makeRoom: func (len: Long) {
		if (this buffer capacity < len)
			this buffer setCapacity(len * 2)
		if (this buffer size < len)
			this buffer size = len
	}
	write: override func ~chr (chr: Char) {
		this _makeRoom(this pos + 1)
		this buffer data[this pos] = chr
		this pos += 1
	}
	seek: func (p: Long) {
		if (p < 0 || p > this buffer size)
			raise("Seeking out of bounds! p = %d, size = %d" format(p, this buffer size))
		this pos = p
	}
	write: override func (chars: Char*, length: SizeT) -> SizeT {
		this _makeRoom(this pos + length)
		memcpy(this buffer data + this pos, chars, length)
		this pos += length
		length
	}
}
