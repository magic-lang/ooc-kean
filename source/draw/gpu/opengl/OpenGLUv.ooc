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
import backend/GLTexture
import OpenGLCanvas, OpenGLPacked, OpenGLContext, OpenGLMap

version(!gpuOff) {
OpenGLUv: class extends OpenGLPacked {
	channelCount: static Int = 2
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Uv, size, stride, data), This channelCount, context)
		this coordinateSystem = coordinateSystem
	}
	init: func (size: IntSize2D, context: OpenGLContext) {
		this init(size, size width * This channelCount, null, CoordinateSystem YUpward, context)
	}
	init: func ~fromTexture (texture: GLTexture, context: OpenGLContext) { super(texture, This channelCount, context) }
	init: func ~fromRaster (rasterImage: RasterUv, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: func -> RasterImage {
		packed := this context createBgra(IntSize2D new(this size width / 2, this size height))
		this context packToRgba(this, packed, IntBox2D new(packed size))
		buffer := packed canvas readPixels()
		result := RasterUv new(buffer, this size)
		packed free()
		result
	}
	_createCanvas: override func -> GpuSurface {
		result := super()
		result pen = Pen new(ColorBgra new(128, 128, 128, 128))
		result
	}
	create: override func (size: IntSize2D) -> This { this context createUv(size) as This }
}
}
