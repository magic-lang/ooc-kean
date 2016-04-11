/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/Reader

Writer: abstract class {
	write: abstract func ~chr (chr: Char)
	write: abstract func (bytes: CString, length: SizeT) -> SizeT
	write: func ~implicitLength (str: String) -> SizeT { this write(str _buffer data, str size) }
	write: func ~bufImplicitLength (buffer: CharBuffer) -> SizeT { this write(buffer data, buffer size) }
	write: func ~strGivenLength (str: String, length: SizeT) -> SizeT { this write(str _buffer data, length) }
	write: func ~fromReaderDefaultBufferSize (source: Reader) { this write(source, 8192) }
	writef: final func (fmt: String, args: ...) { this write(fmt format(args as VarArgs)) }
	write: func ~fromReader (source: Reader, bufferSize: SizeT) -> SizeT {
		// bufferSize: size in bytes of the internal transfer buffer
		buffer := CharBuffer new(bufferSize)
		cursor, bytesTransfered: Int
		cursor = 0
		bytesTransfered = 0
		while (source hasNext()) {
			buffer setLength( source read(buffer data, cursor, bufferSize) )
			bytesTransfered += this write(buffer data, buffer size)
		}
		buffer free()
		bytesTransfered
	}
	close: abstract func
}
