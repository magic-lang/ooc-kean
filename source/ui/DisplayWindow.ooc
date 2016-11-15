/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry
import x11/UnixWindow
import win32/Win32DisplayWindow
import GuiEvent

DisplayWindow: abstract class {
	_mousePressHandler: Event1<MouseEvent>
	_mouseReleaseHandler: Event1<MouseEvent>
	_keyPressHandler: Event1<KeyboardEvent>
	_keyReleaseHandler: Event1<KeyboardEvent>
	init: func
	free: override func {
		if (this _mousePressHandler)
			this _mousePressHandler free()
		if (this _mouseReleaseHandler)
			this _mouseReleaseHandler free()
		if (this _keyPressHandler)
			this _keyPressHandler free()
		if (this _keyReleaseHandler)
			this _keyReleaseHandler free()
		super()
	}
	draw: abstract func (image: Image)
	refresh: virtual func
	addMousePressHandler: func (handler: Event1<MouseEvent>) {
		this _mousePressHandler = this _mousePressHandler ? this _mousePressHandler add(handler) : handler
	}
	addMouseReleaseHandler: func (handler: Event1<MouseEvent>) {
		this _mouseReleaseHandler = this _mouseReleaseHandler ? this _mouseReleaseHandler add(handler) : handler
	}
	addKeyPressHandler: func (handler: Event1<KeyboardEvent>) {
		this _keyPressHandler = this _keyPressHandler ? this _keyPressHandler add(handler) : handler
	}
	addKeyReleaseHandler: func (handler: Event1<KeyboardEvent>) {
		this _keyReleaseHandler = this _keyReleaseHandler ? this _keyReleaseHandler add(handler) : handler
	}
	_onMousePress: func (event: MouseEvent) {
		if (this _mousePressHandler)
			this _mousePressHandler call(event)
	}
	_onMouseRelease: func (event: MouseEvent) {
		if (this _mouseReleaseHandler)
			this _mouseReleaseHandler call(event)
	}
	_onKeyPress: func (event: KeyboardEvent) {
		if (this _keyPressHandler)
			this _keyPressHandler call(event)
	}
	_onKeyRelease: func (event: KeyboardEvent) {
		if (this _keyReleaseHandler)
			this _keyReleaseHandler call(event)
	}
	create: static func (size: IntVector2D, title: String) -> This {
		result: This = null
		version((unix || apple) && !android)
			result = UnixWindow create(size, title)
		version(windows)
			result = Win32DisplayWindow new(size, title)
		if (result == null)
			Debug error("Platform not supported (DisplayWindow)")
		result
	}
}
