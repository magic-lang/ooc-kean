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
	free: override func {
		if (this _fileWriter != null)
			this _fileWriter free()
		super()
	}
	write: func (row: VectorList<String>) {
		for (i in 0 .. row count) {
			value := StringBuilder new() . add(row[i] clone())
			for (k in 0 .. row[i] length())
				if (row[i][k] whitespace()) {
					value insert(0, "\"")
					value add("\"")
					break
				}
			if (i < row count - 1)
				value add(this _delimiter)
			string := value toString()
			this _fileWriter file write(string)
			for (i in 0 .. value count)
				value[i] free()
			(string, value) free()
		}
		this _fileWriter write("\r\n")
	}
	open: static func (filename: String, delimiter := ',') -> This {
		file := File new(filename)
		result := This new(FileWriter new(file), delimiter)
		file free()
		result
	}
}
