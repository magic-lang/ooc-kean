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

import DisplayWindow
use ooc-geometry
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
		raster := RasterBgra convertFrom(image as RasterImage)
		this _backend draw(raster)
		raster referenceCount decrease()
	}
	refresh: override func {
		_backend peekMessage()
	}
}
}
