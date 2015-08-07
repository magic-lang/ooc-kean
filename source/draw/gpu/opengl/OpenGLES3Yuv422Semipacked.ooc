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
import OpenGLES3/Texture, OpenGLES3Canvas, Map/OpenGLES3Map, Map/OpenGLES3MapPack, OpenGLES3Texture

OpenGLES3Yuv422Semipacked: class extends GpuYuv422Semipacked {
	init: func (size: IntSize2D, context: GpuContext) {
		init(size, size width * 2, null, context)
	}
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer, context: GpuContext) {
		super(OpenGLES3Texture createUv(size, stride, data), size, context)
	}
	init: func ~fromTexture (texture: GpuTexture, size: IntSize2D, context: GpuContext) {
		super(texture, size, context)
	}
	init: func ~fromRaster (rasterImage: RasterYuv422Semipacked, context: GpuContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
	}
	toRasterDefault: func -> RasterImage {
		raise("toRaster not implemented for YUV422SEMIPACKED")
		null
	}
	_createCanvas: func -> GpuCanvas {
		result := OpenGLES3Canvas create(this, this _context)
		result clearColor = ColorBgra new(128, 128, 128, 128)
		result
	}

}
