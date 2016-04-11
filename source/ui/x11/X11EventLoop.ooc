/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import external/x11
import ../[EventLoop, DisplayWindow, GuiEvent]
import UnixWindow

version((unix || apple) && !android) {
X11EventLoop: class extends EventLoop {
	init: func
	processEvents: override func (receiver: DisplayWindow) {
		xWindow := (receiver as UnixWindowBase) _xWindow
		while (XPending(xWindow display)) {
			event: XEventOoc
			guiEvent: GuiEvent
			XNextEvent(xWindow display, event&)
			position := IntPoint2D new(event xkey x, event xkey y)
			if (event type == ButtonPress)
				receiver _onMousePress((guiEvent = MouseEvent new(position)) as MouseEvent)
			else if (event type == ButtonRelease)
				receiver _onMouseRelease((guiEvent = MouseEvent new(position)) as MouseEvent)
			else if (event type == KeyPress)
				receiver _onKeyPress((guiEvent = KeyboardEvent new(position, This _lookupCharacter(event&))) as KeyboardEvent)
			else if (event type == KeyRelease)
				receiver _onKeyRelease((guiEvent = KeyboardEvent new(position, This _lookupCharacter(event&))) as KeyboardEvent)
			if (guiEvent)
				guiEvent free()
		}
	}
	_lookupCharacter: static func (event: XEventOoc*) -> Char {
		keySymbol: XKeySymOoc
		buffer: Char[32]
		XLookupString(event as XKeyEventOoc*, buffer[0]&, 32, keySymbol&, null)
		buffer[0]
	}
}
}
