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

CsvReader: class extends Iterator<VectorList<Text>> {
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
	free: func {
		if (this _fileReader != null)
			this _fileReader close() . free()
		super()
	}
	remove: override func -> Bool { false }
	iterator: func -> This { this }
	hasNext: override func -> Bool { this _fileReader hasNext() && this _fileReader peek() != '\0' }
	next: final override func -> VectorList<Text> {
		result: VectorList<Text> = null
		if (this hasNext()) {
			readCharacter: Char
			textBuilder := TextBuilder new()
			while (this _fileReader hasNext() && ((readCharacter = this _fileReader read()) != '\n' && readCharacter != '\0'))
				textBuilder append(readCharacter)
			result = this _parseRow(textBuilder toText())
			textBuilder free()
		}
		result
	}
	_parseRow: func (rowData: Text) -> VectorList<Text> {
		row := rowData take()
		result := VectorList<Text> new()
		rowLength := row count
		readCharacter: Char
		for (i in 0 .. rowLength) {
			textBuilder := TextBuilder new()
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
						textBuilder append(this _extractStringLiteral(row, i&))
					case =>
						textBuilder append(readCharacter)
				}
			}
			result add(textBuilder toText())
			textBuilder free()
		}
		rowData free()
		result
	}
	_extractStringLiteral: func (rowData: Text, position: Int@) -> Text {
		result: Text
		readCharacter: Char
		textBuilder := TextBuilder new()
		rowDataLength := rowData count
		while (position < rowDataLength && (readCharacter = rowData[position]) != '"') {
			textBuilder append(rowData[position])
			position += 1
		}
		position += 1
		result = textBuilder toText()
		textBuilder free()
		result
	}
	open: static func ~text (filename: Text, delimiter := ',', skipHeader := false) -> This {
		filenameString := filename toString()
		result := This open(filenameString, delimiter, skipHeader)
		filenameString free()
		result
	}
	open: static func ~string (filename: String, delimiter := ',', skipHeader := false) -> This {
		result: This = null
		file := File new(filename)
		if (file exists())
			result = This new(FileReader new(file), delimiter, skipHeader)
		file free()
		result
	}
}
