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
use ooc-base
use ooc-math
use ooc-draw
use ooc-draw-gpu
import OpenGLES3/Texture, OpenGLES3Canvas, OpenGLES3Texture

OpenGLES3Bgr: class extends GpuBgr {
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: GpuContext) {
		super(OpenGLES3Texture createBgr(size, stride, data), size, context)
		this coordinateSystem = coordinateSystem
	}
	init: func (size: IntSize2D, context: GpuContext) { this init(size, size width * this _channels, null, CoordinateSystem YUpward, context) }
	init: func ~fromRaster (rasterImage: RasterBgr, context: GpuContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: func -> RasterImage { Debug raise("toRaster not implemented for BGR"); null }
	_createCanvas: func -> GpuCanvas { OpenGLES3Canvas create(this, this _context) }
	create: override func (size: IntSize2D) -> This { This new(size, this _context) }
}
