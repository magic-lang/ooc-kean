/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import DisplayWindow
import EventLoop
import Application

GuiApplication: class extends Application {
	_window: DisplayWindow
	_eventLoop: EventLoop
	window ::= this _window
	init: func ~noWindow (argc: Int, argv: CString*) {
		super(argc, argv)
		this _eventLoop = EventLoop create()
	}
	init: func (argc: Int, argv: CString*, windowSize: IntVector2D, windowName: String) {
		this init~noWindow(argc, argv)
		this createWindow(windowSize, windowName)
	}
	free: override func {
		if (this _window)
			this _window free()
		if (this _eventLoop)
			this _eventLoop free()
		super()
	}
	createWindow: virtual func (windowSize: IntVector2D, windowName: String) {
		if (this _window)
			this _window free()
		this _window = DisplayWindow create(windowSize, windowName)
	}
	processEvents: override func {
		if (this _window)
			this _eventLoop processEvents(this _window)
	}
}
