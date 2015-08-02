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

use ooc-collections
use ooc-base
import CLIParser

vHandle: func {
	println("v flag action")
}
rHandle: func {
	println("r flag action")
}
gcoff: func {
	println("gc=off flag action")
}
lpthread: func {
	println("lpthread flag action")
}
zHandle: func {
	println("z flag action")
}
main: func (argc: Int, argv: CString*) {
	inputList := VectorList<String> new()
	for (i in 1 .. argc) {
		arg := argv[i] toString()
		inputList add(arg)
		//arg  println()
	}
	parser := CLIParser new()
	parser add("version", "v", 0, "", Event new(vHandle))
	parser add("run", "r", 0, "", Event new(rHandle))
	parser add("gc=off", "g", 0, "", Event new(gcoff))
	parser add("message", "m", 1, "", Event1<String> new(func (message: String) {println(message)}))
	parser add("zed", "z", 0, "", Event new(zHandle))
	parser add("number", "n", 1, "", Event1<String> new(func (message: String) {(message as Int) + 10}))
	parser add("path", "p", 1, "", Event1<String> new(func (message: String) {println(message)}))
	parser add("level", "l", 1 , "", Event1<String> new(func (level: String) {_level := (level as Int)}))
	parser parse(inputList, argc-1)
}
