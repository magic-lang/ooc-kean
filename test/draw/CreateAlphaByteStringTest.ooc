/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use draw
use ooc-unit
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

			while (generatedFile hasNext?() && comparisonFile hasNext?()) {
				generatedFile read(generatedBuffer)
				comparisonFile read(comparisonBuffer)
				generatedString := generatedBuffer toString()
				comparisonString := comparisonBuffer toString()
				expect(generatedString, is equal to(comparisonString))
			}

			expect(generatedFile hasNext?(), is false)
			expect(comparisonFile hasNext?(), is false)

			generatedFile free()
			comparisonFile free()
		})
	}
}

CreateAlphaByteStringTest new() run() . free()
