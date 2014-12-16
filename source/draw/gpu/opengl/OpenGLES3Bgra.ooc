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

use ooc-math
use ooc-draw
use ooc-draw-gpu
import OpenGLES3/Texture, OpenGLES3Canvas

OpenGLES3Bgra: class extends GpuBgra {
	backend: Texture { get { this _backend as Texture } }
	init: func (size: IntSize2D, context: GpuContext) {
		init(size, size width * this _channels, null, context)
	}
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, context: GpuContext) {
		super(size, context)
		this _backend = Texture create(TextureType bgra, size width, size height, stride, data) as Pointer
	}
	bind: func (unit: UInt) {
		this backend bind (unit)
	}
	unbind: func {
		this backend unbind()
	}
	dispose: func {
		this backend dispose()
		if (this _canvas != null)
			this _canvas dispose()
	}
	upload: func (raster: RasterPacked) {
		this backend uploadPixels(raster buffer pointer, raster stride)
	}
	setFilter: func (filter: Bool) {
		this backend setFilter(filter)
	}
	generateMipmap: func {
		this backend generateMipmap()
	}
	toRasterDefault: func -> RasterImage {
		buffer := this canvas readPixels(this _channels)
		result := RasterBgra new(buffer, this size)
		buffer referenceCount decrease()
		result
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := OpenGLES3Bgra create(size, this _context)
		target canvas draw(this)
		target
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3Canvas create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterBgra, context: GpuContext) -> This {
		result := This new(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := This new(size, context)
		result backend != null ? result : null
	}

}
