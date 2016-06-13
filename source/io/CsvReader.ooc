/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
import io/[File, FileReader]

CsvReader: class extends Iterator<VectorList<String>> {
	_fileReader: FileReader
	_delimiter: Char
	delimiter ::= this _delimiter

	init: func (=_fileReader, delimiter := ',', skipHeader := false) {
		this _delimiter = delimiter
		if (skipHeader) {
			readCharacter: Char
			while (this _fileReader hasNext() && ((readCharacter = this _fileReader read()) != '\n' && readCharacter != '\0')) { }
		}
	}
	free: override func {
		if (this _fileReader != null)
			this _fileReader free()
		super()
	}
	remove: override func -> Bool { false }
	iterator: func -> This { this }
	hasNext: override func -> Bool { this _fileReader hasNext() && this _fileReader peek() != '\0' }
	next: final override func -> VectorList<String> {
		result: VectorList<String> = null
		if (this hasNext()) {
			readCharacter: Char
			stringBuilder := StringBuilder new()
			while (this _fileReader hasNext() && ((readCharacter = this _fileReader read()) != '\n' && readCharacter != '\0'))
				stringBuilder add(readCharacter)
			result = this _parseRow(stringBuilder toString())
			for (i in 0 .. stringBuilder count)
				stringBuilder[i] free()
			stringBuilder free()
		}
		result
	}
	_parseRow: func (row: String) -> VectorList<String> {
		result := VectorList<String> new()
		rowLength := row length()
		readCharacter: Char
		for (i in 0 .. rowLength) {
			stringBuilder := StringBuilder new()
			while (i < rowLength && ((readCharacter = row[i]) != this _delimiter)) {
				i += 1
				match (readCharacter) {
					case ' ' =>
						continue
					case '\t' =>
						continue
					case '\r' =>
						continue
					case '"' =>
						stringBuilder add(this _extractStringLiteral(row, i&))
					case =>
						stringBuilder add(readCharacter)
				}
			}
			result add(stringBuilder toString())
			for (i in 0 .. stringBuilder count)
				stringBuilder[i] free()
			stringBuilder free()
		}
		result
	}
	_extractStringLiteral: func (rowData: String, position: Int@) -> String {
		result: String
		readCharacter: Char
		stringBuilder := StringBuilder new()
		rowDataLength := rowData length()
		while (position < rowDataLength && (readCharacter = rowData[position]) != '"') {
			stringBuilder add(rowData[position])
			position += 1
		}
		position += 1
		result = stringBuilder toString()
		for (i in 0 .. stringBuilder count)
			stringBuilder[i] free()
		stringBuilder free()
		result
	}
	open: static func (filename: String, delimiter := ',', skipHeader := false) -> This {
		result: This = null
		file := File new(filename)
		if (file exists())
			result = This new(FileReader new(file), delimiter, skipHeader)
		file free()
		result
	}
}
