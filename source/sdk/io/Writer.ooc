/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/Reader

/**
 * The writer interface provides a medium-independent way to write
 * bytes to anything.
 */
Writer: abstract class {
	write: abstract func ~chr (chr: Char)
	write: abstract func (bytes: CString, length: SizeT) -> SizeT
	write: func ~implicitLength (str: String) -> SizeT {
		write(str _buffer data, str size)
	}
	write: func ~bufImplicitLength (buffer: CharBuffer) -> SizeT {
		write(buffer data, buffer size)
	}
	write: func ~strGivenLength (str: String, length: SizeT) -> SizeT {
		write(str _buffer data, length)
	}
	writef: final func (fmt: String, args: ...) {
		write(fmt format(args as VarArgs))
	}
	// bufferSize: size in bytes of the internal transfer buffer
	write: func ~fromReader (source: Reader, bufferSize: SizeT) -> SizeT {
		buffer := CharBuffer new(bufferSize)
		cursor, bytesTransfered: Int
		cursor = 0
		bytesTransfered = 0

		while (source hasNext?()) {
			buffer setLength(source read(buffer data, cursor, bufferSize))
			bytesTransfered += this write(buffer data, buffer size)
		}

		buffer free()
		bytesTransfered
	}
	write: func ~fromReaderDefaultBufferSize (source: Reader) {
		this write(source, 8192)
	}
	close: abstract func
}
