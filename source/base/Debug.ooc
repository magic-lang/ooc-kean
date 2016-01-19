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

use base
import io/FileWriter

DebugLevel: enum {
	Everything
	Debug
	Notification
	Warning
	Recoverable
	Message
	Critical
}

Debug: class {
	_level: static DebugLevel = DebugLevel Everything
	_printFunction: static Func (String) = func (s: String) { println(s) }
	initialize: static func (f: Func (String)) {
		This _printFunction = f
	}
	print: static func (string: String, level := DebugLevel Everything) {
		if (This _level == level || (This _level == DebugLevel Everything) ) {
			This _printFunction(string)
		}
	}
	print: static func ~text (text: Text, level := DebugLevel Everything) {
		string := text toString()
		This print(string, level)
		string free()
	}
	raise: static func (message: String) {
		This print(message)
		raise(message)
	}
	raise: static func ~text (message: Text) {
		string := message toString()
		This raise(string)
		string free()
	}
	kean_base_debug_registerCallback: unmangled static func (print: Pointer) {
		f := (print, null) as Func (Char*)
		This initialize(func (s: String) { f(s toCString()) })
	}
}
