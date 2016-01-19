use base
use collections
use ooc-io
import io/[File, FileWriter]

CsvWriter: class {
	_fileWriter: FileWriter
	init: func (=_fileWriter)
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
				value append(CsvReader delimiter)
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
	open: static func ~text (filename: Text) -> This {
		filenameString := filename toString()
		result := This open(filenameString)
		filenameString free()
		result
	}
	open: static func ~string (filename: String) -> This {
		file := File new(filename)
		result := This new(FileWriter new(file))
		file free()
		result
	}
}
