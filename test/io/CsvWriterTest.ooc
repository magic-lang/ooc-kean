use base
use collections
use ooc-unit
use io
import io/File
CsvWriterTest: class extends Fixture {
	init: func {
		super("CsvWriter")
		this _createOutputDirectory()
		this add("open-write-verify", func {
			// Read original file
			reader := CsvReader open(Text new(c"test/io/input/3x3.csv", 21))
			csvRecords := VectorList<VectorList<Text>> new()
			for (row in reader)
				csvRecords add(row)
			reader free()
			// Write contents of original file to a temporary file
			outputFilename := Text new(c"test/io/output/3x3_temp.csv", 27)
			writer := CsvWriter open(outputFilename)
			for (i in 0 .. csvRecords count)
				writer write(csvRecords[i])
			writer free()
			// Open temporary file and verify content
			reader = CsvReader open(outputFilename)
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i] toString()
					correctAnswer := ((i + 1) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					rowString free(); correctAnswer free()
				}
				row free()
				++rowCounter
			}
			reader free()
			outputFilename free()
			csvRecords free()
		})
	}
	_createOutputDirectory: func {
		file := File new("test/io/output")
		file mkdir()
		file free()
	}
}

CsvWriterTest new() run() . free()
