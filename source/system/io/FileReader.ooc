/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/[Reader, File]

FileReader: class extends Reader {
	file: FStream
	init: func ~withFile (fileObject: File) {
		init(fileObject getPath())
	}
	init: func ~withName (fileName: String) {
		// mingw fseek/ftell are *really* unreliable with text mode
		// if for some reason you need to open in text mode, use
		// FileReader new(fileName, "rt")
		init(fileName, "rb")
	}
	/**
	 * Open a file for reading, given its name and the mode in which to open it.
	 *
	 * "r" = for reading
	 * "w" = for writing
	 * "r+" = for reading and writing
	 *
	 * suffix "a" = appending
	 * suffix "b" = binary mode
	 * suffix "t" = text mode (warning: rewind/mark are unreliable in text mode under mingw32)
	 */
	init: func ~withMode (fileName, mode: String) {
		this file = FStream open(fileName, mode)
		if (!this file) {
			err := getOSError()
			Exception new(This, "Couldn't open #{fileName} for reading: #{err}") throw()
		}
	}
	init: func ~fromFStream (=file)
	free: override func {
		this file close()
		super()
	}
	read: override func (buffer: CString, offset: Int, count: Int) -> SizeT {
		this file read(buffer + offset, count)
	}
	read: func ~fullBuffer (buffer: CharBuffer) {
		count := this file read(buffer data, buffer capacity)
		buffer size = count
	}
	read: override func ~char -> Char {
		this file readChar()
	}
	hasNext: override func -> Bool {
		feof(this file) == 0
	}
	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		this file seek(offset, match mode {
			case SeekMode SET => SEEK_SET
			case SeekMode CUR => SEEK_CUR
			case SeekMode END => SEEK_END
			case =>
				Exception new("Invalid seek mode: %d" format(mode)) throw()
				SEEK_SET
		}) == 0
	}
	mark: override func -> Long {
		this marker = this file tell()
		this marker
	}
}
