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
	init: func ~gpuImages (y: OpenGLES3Monochrome, u: OpenGLES3Monochrome, v: OpenGLES3Monochrome, context: GpuContext) {
		super(y size, context)
		this _y = y
		this _u = u
		this _v = v
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Planar create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterYuv420Planar, context: GpuContext) -> This {
		y := OpenGLES3Monochrome create(rasterImage y, context)
		u := OpenGLES3Monochrome create(rasterImage u, context)
		v := OpenGLES3Monochrome create(rasterImage v, context)
		result := This new(y, u, v, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := This new(size, context)
		result _y = OpenGLES3Monochrome create(size, context)
		result _u = OpenGLES3Monochrome create(IntSize2D new (size width, size height / 4), context)
		result _v = OpenGLES3Monochrome create(IntSize2D new (size width, size height / 4), context)
		result
	}
}
