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
			filename := "test/io/input/3x3.csv"
			reader := CsvReader open(filename)
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i]
					correctAnswer := ((i + 1) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					correctAnswer free()
				}
				row free()
				rowCounter += 1
			}
			reader free()
		})
		this add("string literals", func {
			filename := "test/io/input/strings.csv"
			reader := CsvReader open(filename)
			correctStrings := ["mary had a little lamb", "hello from row #2"]
			position := 0
			for (row in reader) {
				stringBuilder := StringBuilder new()
				for (i in 0 .. row count)
					stringBuilder add(row[i])
				result := stringBuilder join("")
				expect(result, is equal to(correctStrings[position]))
				(row, result, stringBuilder) free()
				correctStrings[position] free()
				position += 1
			}
			(correctStrings, reader) free()
		})
		this add("non-default delimiter", func {
			filename := "test/io/input/semicolondelimiter.csv"
			reader := CsvReader open(filename, ';')
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i]
					correctAnswer := ((i + 1) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					correctAnswer free()
				}
				row free()
				rowCounter += 1
			}
			expect(reader delimiter, is equal to(';'))
			(filename, reader) free()
		})
		this add("skip header", func {
			filename := "test/io/input/semicolondelimiter.csv"
			reader := CsvReader open(filename, ';', true)
			rowCounter := 0
			for (row in reader) {
				for (i in 0 .. row count) {
					rowString := row[i]
					correctAnswer := ((i + 4) + rowCounter * 3) toString()
					expect(rowString, is equal to(correctAnswer))
					correctAnswer free()
				}
				row free()
				rowCounter += 1
			}
			expect(reader delimiter, is equal to(';'))
			reader free()
		})
	}
}

CsvReaderTest new() run() . free()
