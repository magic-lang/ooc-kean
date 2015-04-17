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
import OpenGLES3/Texture, OpenGLES3Canvas, OpenGLES3Texture

OpenGLES3Bgr: class extends GpuBgr {
	init: func (size: IntSize2D, context: GpuContext) {
		this init(size, size width * this _channels, null, context)
	}
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, context: GpuContext) {
		super(OpenGLES3Texture createBgr(size, stride, data), size, context)
	}
	toRasterDefault: func -> RasterImage {
		raise("toRaster not implemented for BGR")
		null
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3Canvas create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterBgr, context: GpuContext) -> This {
		result := This new(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := This new(size, context)
		result texture != null ? result : null
	}
}
