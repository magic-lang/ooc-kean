use ooc-base
use ooc-collections
import io/[File, FileReader]

CsvReader: class extends Iterator<VectorList<Text>> {
	_fileReader: FileReader
	init: func (=_fileReader)
	free: func {
		if (this _fileReader != null) {
			this _fileReader close()
			this _fileReader free()
		}
		super()
	}
	remove: override func -> Bool { false }
	iterator: func -> This { this }
	hasNext?: override func -> Bool { this _fileReader hasNext?() }
	next: final override func -> VectorList<Text> {
		result: VectorList<Text>
		if (this hasNext?()) {
			readCharacter: Char
			textBuilder := TextBuilder new()
			while (this _fileReader hasNext?() && ((readCharacter = this _fileReader read()) != '\n' && readCharacter != '\0'))
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
			while (i < rowLength && ((readCharacter = row[i]) != This delimiter)) {
				++i
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
	delimiter ::= static ','
	open: static func ~text (filename: Text) -> This {
		filenameString := filename toString()
		result := This open(filenameString)
		filenameString free()
		result
	}
	open: static func ~string (filename: String) -> This {
		result: This = null
		file := File new(filename)
		if (file exists())
			result = This new(FileReader new(file))
		file free()
		result
	}
}
