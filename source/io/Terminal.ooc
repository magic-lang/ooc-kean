/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Terminal: class {
	//Note: The following does not work for the regular Win32 shell, but we don't use it
	setColor: static func (foreground, background: TerminalColor) {
		This setForegroundColor(foreground)
		This setBackgroundColor(background)
	}
	setForegroundColor: static func (color: TerminalColor) {
		This _output(color as Int)
	}
	setBackgroundColor: static func (color: TerminalColor) {
		This _output(color as Int + 10)
	}
	setAttribute: static func (attribute: TerminalAttribute) {
		This _output(attribute as Int)
	}
	reset: static func {
		This setAttribute(TerminalAttribute reset)
	}
	_output: static func (code: Int) {
		"\033[%dm" format(code) print()
		fflush(stdout)
	}
}

TerminalAttribute: enum {
	reset = 0
	bright = 1
	dim = 2
	under = 4
	blink = 5
	reverse = 7
	hidden = 8
}

TerminalColor: enum {
	black = 30
	red
	green
	yellow
	blue
	magenta
	cyan
	grey
	white
}
