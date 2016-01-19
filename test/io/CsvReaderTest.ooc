use ooc-base
use ooc-collections
use ooc-unit
use ooc-io

CsvReaderTest: class extends Fixture {
	init: func {
		super("CsvReader")
		this add("verify entries", func {
			filename := Text new(c"test/io/input/3x3.csv", 21)
			reader := CsvReader open(filename)
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
			filename free()
			reader free()
		})
		this add("string literals", func {
			filename := Text new(c"test/io/input/strings.csv", 25)
			reader := CsvReader open(filename)
			correctTexts := [Text new(c"mary had a little lamb", 22), Text new(c"hello from row #2", 17)]
			position := 0
			for (row in reader) {
				textBuilder := TextBuilder new()
				for (i in 0 .. row count)
					textBuilder append(row[i])
				expect(textBuilder toText(), is equal to(correctTexts[position]))
				row free()
				correctTexts[position] free()
				textBuilder free()
				++position
			}
			correctTexts free()
			filename free()
			reader free()
		})
	}
}

CsvReaderTest new() run() . free()
