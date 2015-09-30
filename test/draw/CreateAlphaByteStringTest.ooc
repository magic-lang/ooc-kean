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

use ooc-draw
use ooc-unit
import ../../source/draw/CreateAlphaByteString
import io/[File, FileWriter]

CreateAlphaByteStringTest: class extends Fixture {
	init: func {
		super("CreateAlphaByteStringTest [TODO: Not implemented]")
    }
}

outputData := CreateAlphaByteString makeAlphaString("test/draw/input/logo.png", "logo")
filename := "test/draw/output/"
file := File new(filename)
folder := file parent . mkdirs() . free()
file free()
fw := FileWriter new(filename + "DataFile.ooc")
fw write(outputData)
fw close()
