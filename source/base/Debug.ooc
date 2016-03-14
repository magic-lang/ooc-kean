/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
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
		(This _printFunction as Closure) free()
		This _printFunction = f
	}
	print: static func (string: String, level := DebugLevel Everything) {
		if (This _level == level || (This _level == DebugLevel Everything))
			This _printFunction(string)
	}
	print: static func ~text (text: Text, level := DebugLevel Everything) {
		string := text toString()
		This print(string, level)
		string free()
	}
	error: static func (message: String) {
		This print(message)
		raise(message)
	}
	error: static func ~text (message: Text) {
		string := message toString()
		This error(string)
		string free()
	}
	free: static func ~all {
		(This _printFunction as Closure) free()
	}
}

GlobalCleanup register(|| Debug free~all())
