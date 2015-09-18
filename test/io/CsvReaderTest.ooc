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
				for (i in 0 .. row count)
					expect(row[i], is equal to(((i + 1) + rowCounter * 3) toString()))
				++rowCounter
			}
			reader free()
		})
		this add("strings", func {
			filename := Text new(c"test/io/input/strings.csv", 25)
			reader := CsvReader open(filename)
			textBuilder := TextBuilder new()
			for (row in reader) {
				for (i in 0 .. row count)
					textBuilder append(row[i])
			}
			expect(textBuilder toString(), is equal to("mary had a little lamb"))
			textBuilder free()
			reader free()
		})
	}
}
CsvReaderTest new() run()
