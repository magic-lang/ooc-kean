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
import OpenGLES3Canvas, Map/OpenGLES3Map, Map/OpenGLES3MapPack, OpenGLES3Texture

OpenGLES3Monochrome: class extends GpuMonochrome {
	init: func (size: IntSize2D, context: GpuContext) {
		init(size, size width, null, context)
	}
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, context: GpuContext) {
		super(OpenGLES3Texture createMonochrome(size, stride, data), size, context)
	}
	init: func ~fromTexture (texture: GpuTexture, size: IntSize2D, context: GpuContext) { super(texture, size, context) }
	toRasterDefault: func -> RasterImage {
		packed := this _context createBgra(IntSize2D new(this size width / 4, this size height))
		packMap := this _context getMap(this, GpuMapType pack) as OpenGLES3MapPackMonochrome
		packMap imageWidth = this size width
		packed canvas draw(this, packMap, Viewport new(packed size))
		buffer := packed canvas readPixels()
		result := RasterMonochrome new(buffer, this size)
		packed recycle()
		result
	}
	toRasterDefault: func ~overwrite (rasterImage: RasterImage) {
		raise("toRaster not implemented for MONOCHROME")
		null
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3Canvas create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterMonochrome, context: GpuContext) -> This {
		result := This new(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := This new(size, context)
		result texture != null ? result : null
	}

}
