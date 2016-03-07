/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use io
import io/[File, FileWriter]

CsvWriter: class {
	_fileWriter: FileWriter
	_delimiter: Char
	delimiter ::= this _delimiter
	init: func (=_fileWriter, delimiter := ',') {
		this _delimiter = delimiter
	}
	free: func {
		if (this _fileWriter != null) {
			this _fileWriter close()
			this _fileWriter free()
		}
		super()
	}
	write: func (row: VectorList<Text>) {
		for (i in 0 .. row count) {
			value := TextBuilder new(row[i])
			for (k in 0 .. row[i] take() count)
				if (this _isWhitespace(row[i] take()[k])) {
					value prepend('\"')
					value append('\"')
					break
				}
			if (i < row count - 1)
				value append(this _delimiter)
			string := value toString()
			this _fileWriter file write(string)
			string free()
			value free()
		}
		this _fileWriter write("\r\n")
	}
	_isWhitespace: func (value: Char) -> Bool {
		value == '\t' || value == ' ' || value == '\r' || value == '\n'
	}
	open: static func ~text (filename: Text, delimiter := ',') -> This {
		filenameString := filename toString()
		result := This open(filenameString, delimiter)
		filenameString free()
		result
	}
	open: static func ~string (filename: String, delimiter := ',') -> This {
		file := File new(filename)
		result := This new(FileWriter new(file), delimiter)
		file free()
		result
	}
}
