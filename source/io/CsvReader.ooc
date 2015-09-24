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
	remove: func -> Bool { false }
	iterator: func -> This { this }
	hasNext?: func -> Bool { this _fileReader hasNext?() }
	next: func -> VectorList<Text> {
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
		result := VectorList<Text> new()
		rowDataLength := rowData count
		readCharacter: Char
		for (i in 0 .. rowDataLength) {
			textBuilder := TextBuilder new()
			while (i < rowDataLength && ((readCharacter = rowData[i]) != ';')) {
				++i
				match (readCharacter) {
					case ' ' =>
						continue
					case '\t' =>
						continue
					case '\r' =>
						continue
					case '"' =>
						textBuilder append(this _extractStringLiteral(rowData, i&))
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
	open: static func (filename: Text) -> This {
		result: This = null
		file := File new(filename toString())
		if (file exists?())
			result = This new(FileReader new(file))
		file free()
		result
	}
}
