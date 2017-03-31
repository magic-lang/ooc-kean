/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import DisplayWindow
import x11/X11EventLoop
import win32/Win32EventLoop

EventLoop: abstract class {
	init: func
	processEvents: abstract func (receiver: DisplayWindow)
	create: static func -> This {
		result: This
		version((unix || apple) && !android)
			result = X11EventLoop new()
		version(windows)
			result = Win32EventLoop new()
		result
	}
}
