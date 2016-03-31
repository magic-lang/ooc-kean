/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import DisplayWindow
use geometry
use draw
import Win32Window

version(windows) {
Win32DisplayWindow: class extends DisplayWindow {
	_backend: Win32Window
	init: func (size: IntVector2D, title: String) {
		super()
		this _backend = Win32Window new(size, title)
	}
	free: override func {
		this _backend free()
		super()
	}
	draw: override func (image: Image) {
		raster := RasterRgba convertFrom(image as RasterImage)
		this _backend draw(raster)
		raster referenceCount decrease()
	}
	refresh: override func {
		this _backend peekMessage()
	}
}
}
