/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use ui
import external/x11
use draw

version((unix || apple) && !android) {
X11Window: class extends NativeWindow {
	_x11GraphicsContext: GraphicsContextX11
	_defaultScreen := 0
	_displayDepth := 0
	_cacheSize: IntVector2D
	_xImage: XImageOoc*
	init: func (size: IntVector2D, title: String) {
		this _xImage = null
		/* Note: ":0" is the usual identifier for the default display but this should be read from the DISPLAY variable in the system by passing null as parameter,
		i.e. this _display = XOpenDisplay(null) */
		display := XOpenDisplay(null)
		if (display == null) {
			"Failed to find default display identifier in DISPLAY variable, guessing :0 instead" println()
			display = XOpenDisplay(":0")
		}
		if (display == null)
			raise("Unable to open X Display")
		this _defaultScreen = XDefaultScreen(display)
		this _displayDepth = DefaultDepth(display, this _defaultScreen)
		root: Long = DefaultRootWindow(display)
		swa: XSetWindowAttributesOoc
		swa eventMask = ExposureMask | PointerMotionMask | KeyPressMask | ButtonPressMask
		backend := XCreateWindow(display, root, 0, 0, size x, size y, 0u, CopyFromParent as Int, InputOutput as UInt, null, CWEventMask, swa&)

		this _x11GraphicsContext = XCreateGC(display, backend, 0, 0)
		XSetBackground(display, this _x11GraphicsContext, 0)
		//Disable fit to screen
		sh: XSizeHintsOoc
		sh width = sh min_width = size x
		sh height = sh min_height = size y
		sh flags = PSize | PMinSize | PPosition
		XSetWMNormalHints(display, backend, sh&)

		XMapWindow(display, backend)
		XStoreName(display, backend, title)
		super(size, backend, display)

		XSelectInput(display, backend, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask)
		XkbSetDetectableAutoRepeat(display, true, null) as Void

		this resize(size)
	}
	free: override func {
		if (this _xImage)
			XDestroyImage(this _xImage)
		XFreeGC(this display, this _x11GraphicsContext)
		XDestroyWindow(this display, this backend)
		XCloseDisplay(this display)
		super()
	}
	resize: func (size: IntVector2D) { XResizeWindow(this display, this backend, size x, size y) }
	draw: func (image: RasterRgba) {
		if (this _cacheSize != image size) {
			if (this _xImage)
				XDestroyImage(this _xImage)
			imageData := calloc(image height * image stride, 4)
			this _xImage = XCreateImage(this display, CopyFromParent, this _displayDepth, ZPixmap, 0, imageData, image width, image height, 8, 0)
			this _cacheSize = image size
		}
		memcpy(this _xImage@ data, image buffer pointer, image buffer size)
		XClearWindow(this display, this backend)
		XPutImage(this display, this backend, this _x11GraphicsContext, this _xImage, 0, 0, 0, 0, image width, image height)
	}
}
}
