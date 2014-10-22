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

import OpenGLES3Canvas, OpenGLES3Monochrome

OpenGLES3Yuv420Planar: class extends GpuYuv420Planar {
	init: func (size: IntSize2D, context: GpuContext) { super(size, context) }
	dispose: func {
		if (this _canvas != null)
			this _canvas dispose()
		this _y dispose()
		this _u dispose()
		this _v dispose()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _u bind(unit + 1)
		this _v bind(unit + 2)
	}
	toRaster: func -> RasterImage { return null }
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Planar create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterYuv420Planar, context: GpuContext) -> This {
		result := context getRecycled(GpuImageType yuvPlanar, rasterImage size) as This
		if (result != null) {
			(result _y as OpenGLES3Monochrome) backend uploadPixels(rasterImage y pointer)
			(result _u as OpenGLES3Monochrome) backend uploadPixels(rasterImage u pointer)
			(result _v as OpenGLES3Monochrome) backend uploadPixels(rasterImage v pointer)
		}
		else {
			result = This new(rasterImage size, context)
			result _y = OpenGLES3Monochrome create(rasterImage y, context)
			result _u = OpenGLES3Monochrome create(rasterImage u, context)
			result _v = OpenGLES3Monochrome create(rasterImage v, context)
		}
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := context getRecycled(GpuImageType yuvPlanar, size) as This
		if (result == null) {
			result = This new(size, context)
			result _y = OpenGLES3Monochrome create(size, context)
			result _u = OpenGLES3Monochrome create(IntSize2D new (size width, size height / 4), context)
			result _v = OpenGLES3Monochrome create(IntSize2D new (size width, size height / 4), context)
		}
		result
	}
}
