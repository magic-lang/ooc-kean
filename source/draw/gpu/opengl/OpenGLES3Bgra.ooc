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
	replace: func (image: RasterBgra) {
		this backend uploadPixels(image pointer)
	}
	bind: func (unit: UInt) {
		this backend bind (unit)
	}
	dispose: func {
		this backend dispose()
		if (this _canvas != null)
			this _canvas dispose()
	}
	generateMipmap: func {
		this backend generateMipmap()
	}
	toRasterDefault: func -> RasterImage {
		buffer := this canvas readPixels(this _channels)
		result := RasterBgra new(buffer, this size)
		result
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := OpenGLES3Bgra create(size, this _context)
		target canvas draw(this)
		target
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3Canvas create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterBgra, context: GpuContext) -> This {
		result := context getImage(GpuImageType bgra, rasterImage size) as This
		if (result != null)
			result backend uploadPixels(rasterImage pointer)
		else
			result = This new(rasterImage size, rasterImage stride, rasterImage pointer, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := context getImage(GpuImageType bgra, size) as This
		if (result == null)
			result = This new(size, context)
		result backend != null ? result : null
	}

}
