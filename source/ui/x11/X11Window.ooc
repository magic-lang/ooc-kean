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
use ooc-ui
import include/x11

version(unix || apple) {
X11Window: class extends NativeWindow {
	init: func (size: IntSize2D, title: String) {
		/* Note: ":0" is the usual identifier for the default display but this should be read from the DISPLAY variable in the system by passing null as parameter,
		i.e. this _display = XOpenDisplay(null) */
		display := XOpenDisplay(null)
		if (display == null) {
			"Failed to find default display identifier in DISPLAY variable, guessing :0 instead" println()
			display = XOpenDisplay(":0")
		}
		if (display == null)
			raise("Unable to open X Display")
		root: Long = DefaultRootWindow(display)
		swa: XSetWindowAttributesOoc
		swa eventMask = ExposureMask | PointerMotionMask | KeyPressMask | ButtonPressMask
		backend := XCreateWindow(display, root, 0, 0, size width, size height, 0u, CopyFromParent as Int, InputOutput as UInt, null, CWEventMask, swa&)
		//Disable fit to screen
		sh: XSizeHintsOoc
		sh width = sh min_width = size width
		sh height = sh min_height = size height
		sh flags = PSize | PMinSize | PPosition
		XSetWMNormalHints(display, backend, sh&)

		XMapWindow(display, backend)
		XStoreName(display, backend, title)
		super(size, backend, display)

		XSelectInput(display, backend, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask)
		XkbSetDetectableAutoRepeat(display, true, null) as Void

		this resize(size)
	}
	resize: func (size: IntSize2D) { XResizeWindow(this display, this backend, size width, size height) }
	free: override func {
		XCloseDisplay(this display)
		super()
	}
}
}
