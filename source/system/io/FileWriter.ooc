/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import io/[Writer, File]
import io/native/FileUnix

FileWriter: class extends Writer {
	file: FStream

	init: func ~withFile (fileObject: File, append: Bool) {
		this init(fileObject getPath(), append)
	}
	init: func ~withFileOverwrite (fileObject: File) {
		this init(fileObject, false)
	}
	init: func ~withFileAndFlags (fileObject: File, flags: Int) {
		this init(fileObject getPath(), "wb", flags)
	}
	init: func ~withName (fileName: String, append: Bool) {
		// mingw fseek/ftell are *really* unreliable with text mode
		// if for some reason you need to open in text mode, use
		// FileWriter new(fileName, "at") or "wt"
		this init(fileName, append ? "ab" : "wb")
	}
	init: func ~withMode (fileName, mode: String) {
		this file = FStream open(fileName, mode)
		if (!file)
			Exception new(This, "Error creating FileWriter for: " + fileName) throw()
	}
	init: func ~withModeAndFlags (fileName, mode: String, flags: Int) {
		this file = FStream open(fileName, mode, flags)
		if (!file)
			Exception new(This, "File not found: " + fileName) throw()
	}
	init: func ~withFStream (=file)
	init: func ~withNameOverwrite (fileName: String) { this init(fileName, false) }
	write: override func (bytes: Char*, length: SizeT) -> SizeT { this file write(bytes, 0, length) }
	write: override func ~chr (chr: Char) { this file write(chr) }
	close: override func { this file close() }

	createTempFile: static func (pattern, mode: String) -> This {
		result: This
		version (!windows) {
			result = new(FileUnix createTempFile(pattern, mode))
		} else {
			// mkstemp is missing on Windows
			result = new(mktemp(pattern) toString(), mode)
		}
		result
	}
}
