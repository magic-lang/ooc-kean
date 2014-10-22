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
use ooc-draw-gpu
use ooc-draw
import OpenGLES3Canvas, OpenGLES3Monochrome, OpenGLES3Uv

OpenGLES3Yuv420Semiplanar: class extends GpuYuv420Semiplanar {
	init: func (size: IntSize2D, context: GpuContext) { super(size, context) }
	dispose: func {
		if (this _canvas != null)
			this _canvas dispose()
		this _y dispose()
		this _uv dispose()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _uv bind(unit + 1)
	}
	toRaster: func -> RasterImage { return null }
	resizeTo: func (size: IntSize2D) -> This {
		target := OpenGLES3Yuv420Semiplanar create(size, this _context)
		target canvas draw(this)
		target
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Semiplanar create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) -> This {
		result := context getImage(GpuImageType yuvSemiplanar, rasterImage size) as This
		if (result != null) {
			(result _y as OpenGLES3Monochrome) backend uploadPixels(rasterImage y pointer)
			(result _uv as OpenGLES3Uv) backend uploadPixels(rasterImage uv pointer)
		}
		else {
			result = This new(rasterImage size, context)
			result _y = OpenGLES3Monochrome create(rasterImage y, context)
			result _uv = OpenGLES3Uv create(rasterImage uv, context)
		}
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := context getImage(GpuImageType yuvSemiplanar, size) as This
		if (result == null) {
			result := This new(size, context)
			result _y = OpenGLES3Monochrome create(size, context)
			result _uv = OpenGLES3Uv create(IntSize2D new(size width, size height / 2), context)
		}
		result
	}
}
