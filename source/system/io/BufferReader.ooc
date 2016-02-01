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
	init: func ~withString (string: String) {
		this buffer = string _buffer
	}
	buffer: func -> CharBuffer { this buffer }
	close: override func
	read: override func (dest: Char*, destOffset: Int, maxRead: Int) -> SizeT {
		if (marker >= this buffer size)
			Exception new(This, "Buffer overflow! Offset is larger than buffer size.") throw()

		copySize := (marker + maxRead > buffer size ? buffer size - marker : maxRead)
		memcpy(dest, this buffer data + marker, copySize)
		marker += copySize
		copySize
	}
	peek: func -> Char {
		this buffer get(marker)
	}
	read: override func ~char -> Char {
		c := this buffer get(marker)
		marker += 1
		c
	}
	hasNext: override func -> Bool {
		marker < this buffer size
	}
	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		match mode {
			case SeekMode SET =>
				marker = offset
			case SeekMode CUR =>
				marker += offset
			case SeekMode END =>
				marker = this buffer size + offset
		}
		this _clampMarker()
		true
	}
	_clampMarker: func {
		if (marker < 0)
			marker = 0
		if (marker >= this buffer size)
			marker = this buffer size - 1
	}
	mark: override func -> Long {
		marker
	}
}
