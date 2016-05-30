/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/Reader

BufferReader: class extends Reader {
	buffer: CharBuffer

	init: func ~withBuffer (=buffer)
	init: func ~withString (string: String) { this init(string _buffer) }
	buffer: func -> CharBuffer { this buffer }
	mark: override func -> Long { this marker }
	peek: func -> Char { this buffer get(this marker) }
	hasNext: override func -> Bool { this marker < this buffer size }
	read: override func (dest: Char*, destOffset: Int, maxRead: Int) -> SizeT {
		raise(this marker >= this buffer size, "Buffer overflow! Offset is larger than buffer size.", This)
		copySize := (this marker + maxRead > this buffer size ? this buffer size - this marker : maxRead)
		memcpy(dest, this buffer data + this marker, copySize)
		this marker += copySize
		copySize
	}
	read: override func ~char -> Char {
		c := this buffer get(this marker)
		this marker += 1
		c
	}
	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		match mode {
			case SeekMode SET =>
				this marker = offset
			case SeekMode CUR =>
				this marker += offset
			case SeekMode END =>
				this marker = this buffer size + offset
		}
		this _clampMarker()
		true
	}
	_clampMarker: func {
		if (this marker < 0)
			this marker = 0
		if (this marker >= this buffer size)
			this marker = this buffer size - 1
	}
}
