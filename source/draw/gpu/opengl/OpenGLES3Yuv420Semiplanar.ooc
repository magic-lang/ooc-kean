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
	init: func ~gpuImages (y: OpenGLES3Monochrome, uv: OpenGLES3Uv, context: GpuContext) {
		super(y size, context)
		this _y = y
		this _uv = uv
	}
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
	toRasterDefault: func -> RasterImage {
		y := this _y toRaster()
		uv := this _uv toRaster()
		result := RasterYuv420Semiplanar new(y as RasterMonochrome, uv as RasterUv)
		result
	}
	toRasterDefault: func ~overwrite (rasterImage: RasterImage) {
		semiPlanar := rasterImage as RasterYuv420Semiplanar
		this _y toRasterDefault(semiPlanar y)
		this _uv toRasterDefault(semiPlanar uv)
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := OpenGLES3Yuv420Semiplanar create(size, this _context)
		target canvas draw(this)
		target
	}
	_createCanvas: func -> GpuCanvas { OpenGLES3CanvasYuv420Semiplanar create(this, this _context) }

	create: static func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) -> This {
		result := context getImage(GpuImageType yuvSemiplanar, rasterImage size) as This
		if (result == null) {
			y := OpenGLES3Monochrome create(rasterImage y, context)
			uv := OpenGLES3Uv create(rasterImage uv, context)
			result = This new(y, uv, context)
		}
		else {
			(result _y as OpenGLES3Monochrome) backend uploadPixels(rasterImage y pointer, rasterImage y stride)
			(result _uv as OpenGLES3Uv) backend uploadPixels(rasterImage uv pointer, rasterImage uv stride)
		}
		result
	}
	create: static func ~empty (size: IntSize2D, context: GpuContext) -> This {
		result := context getImage(GpuImageType yuvSemiplanar, size) as This
		if (result == null) {
			result = This new(size, context)
			result _y = OpenGLES3Monochrome create(size, context)
			result _uv = OpenGLES3Uv create(size / 2, context)
		}
		result
	}

}
