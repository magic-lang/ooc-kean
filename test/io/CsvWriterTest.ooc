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
import io/File
CsvWriterTest: class extends Fixture {
	init: func {
		super("CsvWriter")
		this _createOutputDirectory()
		this add("open-write-verify", func {
			// Read original file
			reader := CsvReader open(t"test/io/input/3x3.csv")
			csvRecords := VectorList<VectorList<Text>> new()
			for (row in reader)
				csvRecords add(row)
			reader free()
			// Write contents of original file to a temporary file
			outputFilename := t"test/io/output/3x3_temp.csv"
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
					(rowString, correctAnswer) free()
				}
				row free()
				rowCounter += 1
			}
			(reader, outputFilename, csvRecords) free()
		})
		this add("non-default delimiter", func {
			// Read original file
			reader := CsvReader open(t"test/io/input/semicolondelimiter.csv", ';')
			csvRecords := VectorList<VectorList<Text>> new()
			for (row in reader)
				csvRecords add(row)
			reader free()
			// Write contents of original file to a temporary file
			outputFilename := t"test/io/output/semicolondelimiter_temp.csv"
			writer := CsvWriter open(outputFilename, ';')
			for (i in 0 .. csvRecords count)
				writer write(csvRecords[i])
			expect(writer delimiter, is equal to(';'))
			writer free()
			// Open temporary file and verify content
			reader = CsvReader open(outputFilename, ';')
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
			(reader, outputFilename, csvRecords) free()
		})
	}
	_createOutputDirectory: func {
		file := File new("test/io/output")
		file mkdir()
		file free()
	}
}

CsvWriterTest new() run() . free()
