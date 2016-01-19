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

use base
use draw
use ooc-geometry
import x11/UnixWindow
import win32/Win32DisplayWindow
import GuiEvent

DisplayWindow: abstract class {
	_mousePressHandler: Event1<MouseEvent>
	_mouseReleaseHandler: Event1<MouseEvent>
	_keyPressHandler: Event1<KeyboardEvent>
	_keyReleaseHandler: Event1<KeyboardEvent>
	init: func (size: IntVector2D, title: String)
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
		version((unix || apple) && !android)
			return UnixWindow create(size, title)
		version(windows)
			return Win32DisplayWindow new(size, title)
		raise("Platform not supported (DisplayWindow)")
		null
	}
}
