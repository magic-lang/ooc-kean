use ooc-base
use ooc-collections
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
			this _fileWriter file write(row[i] toString())
			if (i < row count - 1)
				this _fileWriter write(";")
		}
		this _fileWriter write("\n")
	}
	open: static func (filename: Text) -> This {
		result: This
		file := File new(filename toString())
		result = This new(FileWriter new(file))
		file free()
		result
	}
}
