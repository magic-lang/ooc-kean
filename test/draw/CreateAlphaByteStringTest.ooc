/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use unit
import ../../source/draw/CreateAlphaByteString
import io/[File, FileWriter, FileReader]

CreateAlphaByteStringTest: class extends Fixture {
	init: func {
		super("CreateAlphaByteString")
		this add("CreateAlphaByteString", func {
			outputData := CreateAlphaByteString makeAlphaString("test/draw/input/logo.png", "logo")
			filename := "test/draw/output/"
			file := File new(filename)
			folder := file parent . mkdirs() . free()
			file free()
			fw := FileWriter new(filename + "DataFile.ooc")
			fw write(outputData)
			fw close()
			filename free()
		})
		this add("Output check", func {
			generated := t"test/draw/output/DataFile.ooc"
			comparison := t"test/draw/input/DataFileComparison.ooc"
			generatedFile := FileReader new(generated)
			comparisonFile := FileReader new(comparison)
			generatedBuffer := CharBuffer new()
			comparisonBuffer := CharBuffer new()

			while (generatedFile hasNext() && comparisonFile hasNext()) {
				generatedFile read(generatedBuffer)
				comparisonFile read(comparisonBuffer)
				generatedString := generatedBuffer toString()
				comparisonString := comparisonBuffer toString()
				expect(generatedString, is equal to(comparisonString))
			}

			expect(generatedFile hasNext(), is false)
			expect(comparisonFile hasNext(), is false)

			generatedFile free()
			comparisonFile free()
		})
	}
}

CreateAlphaByteStringTest new() run() . free()
