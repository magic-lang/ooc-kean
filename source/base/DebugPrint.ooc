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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

import Profiling, io/FileWriter

DebugLevels: enum {
	Everything
	Debug
	Notification
	Warning
	Recoverable
	Message
	Critical
}

DebugPrint: class {
	_level: static Int
	printFunctionPointer: static Func (String)
	initialize: static func (f: Func (String)) {
		This printFunctionPointer = f
	}
	print: static func (printOut: String, level: Int = 1) {
		if (This _level == level || (This _level == 1) ) {
			This printFunctionPointer(printOut)
		}
	}
}
