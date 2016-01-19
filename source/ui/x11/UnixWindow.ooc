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

use draw-gpu
use geometry
use draw
use opengl
import DisplayWindow
import X11Window

version((unix || apple) && !android) {
UnixWindowBase: class extends DisplayWindow {
	_xWindow: X11Window
	init: func (size: IntVector2D, title: String) {
		super()
		this _xWindow = X11Window new(size, title)
	}
	free: override func {
		this _xWindow free()
		super()
	}
	draw: override func (image: Image) {
		if (image instanceOf?(RasterBgra))
			this _xWindow draw(image as RasterBgra)
		else {
			raster := RasterBgra convertFrom(image as RasterImage)
			this _xWindow draw(raster)
			raster referenceCount decrease()
		}
	}
	create: static func (size: IntVector2D, title: String) -> This {
		result: This
		version(gpuOff)
			result = This new(size, title)
		else
			result = UnixWindow new(size, title)
		result
	}
}
version(!gpuOff) {
UnixWindow: class extends UnixWindowBase {
	_openGLWindow: OpenGLWindow
	context ::= this _openGLWindow context
	init: func (size: IntVector2D, title: String) {
		super(size, title)
		this _openGLWindow = OpenGLWindow new(this _xWindow size, this _xWindow display, this _xWindow backend)
	}
	free: override func {
		this _openGLWindow free()
		super()
	}
	draw: override func (image: Image) {
		this _openGLWindow draw(image as GpuImage)
	}
	refresh: override func {
		this _openGLWindow refresh()
	}
}
}
}
