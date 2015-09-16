use ooc-collections
use ooc-unit
use ooc-io

CsvReaderTest: class extends Fixture {
	init: func {
		super("CsvReader")
		this add("verify entries", func {
			reader := CsvReader open("test/io/input/3x3.csv")
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count)
					expect(row[i], is equal to(((i + 1) + rowCounter * 3) toString()))
				++rowCounter
			}
			reader free()
		})
	}
}
CsvReaderTest new() run()
