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
	init: func ~gpuImages (y: OpenGLES3Monochrome, uv: OpenGLES3Uv, context: GpuContext) {
		super(y, uv, context)
		this coordinateSystem = y coordinateSystem
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Semiplanar create(this, this _context) }
	create: static func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) -> This {
		y := context createGpuImage(rasterImage y) as OpenGLES3Monochrome
		uv := context createGpuImage(rasterImage uv) as OpenGLES3Uv
		result := This new(y, uv, context)
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		y := context createMonochrome(size) as OpenGLES3Monochrome
		uv := context createUv(size / 2) as OpenGLES3Uv
		result := This new(y, uv, context)
		result
	}
}
