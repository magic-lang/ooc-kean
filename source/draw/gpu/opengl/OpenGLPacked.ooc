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
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-draw
use ooc-draw-gpu
import backend/GLTexture
import OpenGLContext, OpenGLCanvas

version(!gpuOff) {
OpenGLPacked: abstract class extends GpuImage {
	_filter: Bool
	filter: Bool {
		get { this _filter }
		set(value) {
			this _backend setMagFilter(InterpolationType Linear)
			this _backend setMinFilter(InterpolationType Linear)
		}
	}
	_backend: GLTexture
	backend ::= this _backend
	_channels: UInt
	channels ::= this _channels
	context ::= this _context as OpenGLContext
	_recyclable := true
	recyclable ::= this _recyclable
	init: func (=_backend, =_channels, context: OpenGLContext) { super(this _backend size, context) }
	free: override func {
		if (this recyclable)
			this context recycle(this)
		else {
			this _backend free()
			super()
		}
	}
	upload: override func (image: RasterImage) {
		if (image instanceOf?(RasterPacked)) {
			raster := image as RasterPacked
			this _backend upload(raster buffer pointer, raster stride)
		}
	}
	_createCanvas: override func -> GpuSurface { OpenGLCanvas new(this, this context) }
}
}
