/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use unit
use io

CsvReaderTest: class extends Fixture {
	init: func {
		super("CsvReader")
		this add("verify entries", func {
			filename := t"test/io/input/3x3.csv"
			reader := CsvReader open(filename)
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i] toString()
					correctAnswer := ((i + 1) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					(rowString, correctAnswer) free()
				}
				row free()
				rowCounter += 1
			}
			filename free()
			reader free()
		})
		this add("string literals", func {
			filename := t"test/io/input/strings.csv"
			reader := CsvReader open(filename)
			correctTexts := [t"mary had a little lamb", t"hello from row #2"]
			position := 0
			for (row in reader) {
				textBuilder := TextBuilder new()
				for (i in 0 .. row count)
					textBuilder append(row[i])
				expect(textBuilder toText(), is equal to(correctTexts[position]))
				row free()
				correctTexts[position] free()
				textBuilder free()
				position += 1
			}
			(correctTexts, filename, reader) free()
		})
		this add("non-default delimiter", func {
			filename := t"test/io/input/semicolondelimiter.csv"
			reader := CsvReader open(filename, ';')
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i] toString()
					correctAnswer := ((i + 1) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					(rowString, correctAnswer) free()
				}
				row free()
				rowCounter += 1
			}
			expect(reader delimiter, is equal to(';'))
			filename free()
			reader free()
		})
		this add("skip header", func {
			filename := t"test/io/input/semicolondelimiter.csv"
			reader := CsvReader open(filename, ';', true)
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i] toString()
					correctAnswer := ((i + 4) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					(rowString, correctAnswer) free()
				}
				row free()
				rowCounter += 1
			}
			expect(reader delimiter, is equal to(';'))
			(filename, reader) free()
		})
	}
}

CsvReaderTest new() run() . free()
