/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import native/[PipeUnix, PipeWin32]
import io/[Reader, Writer]

Pipe: abstract class {
	eof := false
	read: func ~char -> Char {
		c: Char
		howmuch := this read(c& as CString, 1)
		if (howmuch == -1)
			c = '\0'
		c
	}
	read: func ~string (len: Int) -> String {
		buf := CString new(len)
		howmuch := this read(buf, len)
		result: String = null
		if (howmuch != -1) {
			buf[howmuch] = '\0'
			result = buf toString()
		}
		result
	}
	read: func ~buffer (buf: CharBuffer) -> Int {
		bytesRead := this read(buf data, buf capacity)
		if (bytesRead >= 0)
			buf setLength(bytesRead)
		bytesRead
	}
	setNonBlocking: func ~both {
		this setNonBlocking('r')
		this setNonBlocking('w')
	}
	setBlocking: func ~both {
		this setBlocking('r')
		this setBlocking('w')
	}
	read: abstract func ~cstring (buf: CString, len: Int) -> Int
	write: func ~string (str: String) -> Int { this write(str _buffer data, str length()) }
	write: abstract func (data: CString, len: Int) -> Int
	close: abstract func (mode: Char) -> Int
	close: abstract func ~both
	setBlocking: func (end: Char) { raise("This platform doesn't support blocking pipe I/O.") }
	setNonBlocking: func (end: Char) { raise("This platform doesn't support non-blocking pipe I/O.") }
	eof: func -> Bool { this eof }
	reader: func -> PipeReader { PipeReader new(this) }
	writer: func -> PipeWriter { PipeWriter new(this) }
	new: static func -> This {
		result: This = null
		version(unix || apple)
			result = PipeUnix new() as This
		version(windows)
			result = PipeWin32 new() as This
		raise(result == null, "Unsupported platform!\n", This)
		result
	}
}

PipeReader: class extends Reader {
	pipe: Pipe
	init: func (=pipe)
	read: override func (chars: CString, offset: Int, count: Int) -> SizeT {
		bytesRead := this pipe read(chars + offset, count)
		bytesRead >= 0 ? bytesRead : 0
	}
	read: override func ~char -> Char {
		bytesRead := this pipe read()
		bytesRead >= 0 ? bytesRead : 0
	}
	hasNext: override func -> Bool { !this pipe eof() }
	mark: override func -> Long { raise("Seeking is not supported for this source"); -1 }
	seek: override func (offset: Long, mode: SeekMode) -> Bool { raise("Seeking is not supported for this source"); false }
	close: override func { this pipe close('r') }
}

PipeWriter: class extends Writer {
	pipe: Pipe
	init: func (=pipe)
	write: override func ~chr (chr: Char) { this pipe write(chr&, 1) }
	write: override func (bytes: CString, length: SizeT) -> SizeT { this pipe write(bytes, length) }
	close: override func { this pipe close('w') }
}
