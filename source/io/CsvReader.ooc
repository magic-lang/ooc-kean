use ooc-collection

//
// Incomplete!
//

CsvRecord: class {

}

CsvReader: class /*extends Iterator<T>*/ {
	_backend: VectorList<CsvRecord>
	_filename: String
	_position := 0
	init: func (=_filename, =_backend)
	free: func {
		if (this _backend != null)
			this _backend free()
		super()
	}
	map: func <T, S> (function: Func(T) -> S) -> This {
		This new(this _filename, this _backend map(function))
	}
	toArray: func<T> -> T[] {
		//CsvReader open("file") map(|value| value toFloat()) toArray<Float>()

	}
	save: func (filename := this _filename) {
		this
	}
	//
	// Current just ignores newline, all entries are treated as a record
	//
	open: static func (filename: String) -> This {
		file := File new(filename)
		result: This
		if (file exists?()) {
			fileReader := FileReader new(file)
			character: Char
			values := VectorList<String> new()
			while ((character = fileReader read()) != '\0') {
				// Ignore space characters as well?
				if (character == '\r' || character == '\n')
					continue
				stringBuilder := StringBuilder new(character toString())
				while ((character = fileReader read()) != ';' && character != '\r' && character != '\n' && character != '\0')
					stringBuilder append(character toString())
				values add(stringBuilder toString())
				stringBuilder free()
			}
			fileReader close()
			fileReader free()
			file free()
			result = This new(filename, values)
		}
		result
	}
}
