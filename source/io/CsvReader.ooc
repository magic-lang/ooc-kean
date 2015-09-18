use ooc-base
use ooc-collections
import io/[File, FileReader]

// TODO: Use Text instead of String

CsvReader: class extends Iterator<VectorList<String>> {
	_fileReader: FileReader
	init: func (=_fileReader)
	free: func {
		if (this _fileReader != null) {
			this _fileReader close()
			this _fileReader free()
		}
		super()
	}
	open: static func (filename: String) -> This {
		result: This
		file := File new(filename)
		if (file exists?())
			result = This new(FileReader new(file))
		file free()
		result
	}
	remove: func -> Bool { false }
	iterator: func -> This { this }
	hasNext?: func -> Bool {
		this _fileReader hasNext?()
	}
	next: func -> VectorList<String> {
		result: VectorList<String>
		if (this hasNext?()) {
			readCharacter: Char
			stringBuilder := StringBuilder new()
			while (this _fileReader hasNext?() && ((readCharacter = this _fileReader read()) != '\n' && readCharacter != '\0'))
				stringBuilder append(readCharacter toString())
			result = this _parseRow(stringBuilder toString())
			stringBuilder free()
		}
		result
	}
	_parseRow: func (rowData: String) -> VectorList<String> {
		result := VectorList<String> new()
		rowDataLength := rowData length()
		position := 0
		readCharacter: Char
		for (i in 0 .. rowDataLength) {
			stringBuilder := StringBuilder new()
			while (i < rowDataLength && ((readCharacter = rowData[i]) != ';')) {
				++i
				match (readCharacter) {
					case ' ' =>
						continue
					case '"' =>
						stringBuilder append(this _extractStringLiteral(rowData, i&))
					case =>
						stringBuilder append(readCharacter toString())
				}
			}
			result add(stringBuilder toString())
			stringBuilder free()
		}
		rowData free()
		result
	}
	_extractStringLiteral: func (rowData: String, position: Int*) -> String {
		result: String
		readCharacter: Char
		stringBuilder := StringBuilder new()
		rowDataLength := rowData length()
		while (position@ < rowDataLength && (readCharacter = rowData[position@]) != '"') {
			stringBuilder append(rowData[position@] toString())
			++position@
		}
		++position@
		result = stringBuilder toString()
		stringBuilder free()
		result
	}
}
