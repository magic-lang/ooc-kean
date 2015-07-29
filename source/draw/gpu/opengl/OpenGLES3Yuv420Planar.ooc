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
	init: func ~gpuImages (y: OpenGLES3Monochrome, u: OpenGLES3Monochrome, v: OpenGLES3Monochrome, context: GpuContext) {
		super(y, u, v, context)
		this coordinateSystem = y coordinateSystem
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Planar create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterYuv420Planar, context: GpuContext) -> This {
		y := context createGpuImage(rasterImage y) as OpenGLES3Monochrome
		u := context createGpuImage(rasterImage u) as OpenGLES3Monochrome
		v := context createGpuImage(rasterImage v) as OpenGLES3Monochrome
		result := This new(y, u, v, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		y := context createMonochrome(size) as OpenGLES3Monochrome
		u := context createMonochrome(IntSize2D new(size width / 2, size height / 2)) as OpenGLES3Monochrome
		v := context createMonochrome(IntSize2D new(size width / 2, size height / 2)) as OpenGLES3Monochrome
		result := This new(y, u, v, context)
		result
	}
}
