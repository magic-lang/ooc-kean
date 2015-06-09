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
use ooc-math
use ooc-opengl
import include/x11

X11Window: class extends NativeWindow {
	init: func (=_width, =_height, title: String) {
		/* Note: ":0" is the usual identifier for the default display but this should be read from the DISPLAY variable in the system by passing null as parameter,
		i.e. this _display = XOpenDisplay(null) */
		this _display = XOpenDisplay(null)
		if (this _display == null) {
			"Failed to find default display identifier in DISPLAY variable, guessing :0 instead" println()
			this _display = XOpenDisplay(":0")
		}
		if (this _display == null)
			raise("Unable to open X Display")
		root: Long = DefaultRootWindow(this _display)

		swa: XSetWindowAttributesOoc
		swa eventMask = ExposureMask | PointerMotionMask | KeyPressMask | ButtonPressMask
		this _backend = XCreateWindow(this _display, root, 0, 0, this _width, this _height, 0u, CopyFromParent as Int, InputOutput as UInt, null, CWEventMask, swa&)
		//Disable fit to screen
		sh: XSizeHintsOoc
		sh width = sh min_width = this _width
		sh height = sh min_height = this _height
		sh flags = PSize | PMinSize | PPosition
		XSetWMNormalHints(this _display, this _backend, sh&)

		XMapWindow(this _display, this _backend)
		XStoreName(this _display, this _backend, title)
	}
	resize: func (size: IntSize2D) { XResizeWindow(this _display, this _backend, size width, size height) }
	free: override func {
//		XCloseDisplay(this _display)
		super()
	}
}
