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
	canvas: GpuCanvas {
		get {
			if (this _canvas == null)
				this _canvas = OpenGLES3CanvasYuv420Semiplanar create(this)
			this _canvas
		}
	}
	init: func (size: IntSize2D) { super(size) }
	dispose: func {
		if (this _canvas != null)
			this _canvas dispose()
		this _y dispose()
		this _uv dispose()
	}
	recycle: func {
		this _y recycle()
		this _uv recycle()
		if(this _canvas != null)
			this _canvas dispose()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _uv bind(unit + 1)
	}
	_generate: func (stride: UInt, y: Pointer, uv: Pointer) -> Bool {
		this _y = OpenGLES3Monochrome _create(this size, stride, y)
		this _uv = OpenGLES3Uv _create(this size / 2, stride, uv)
		this _y != null && this _uv != null
	}
	createStatic: static func ~fromRaster (rasterImage: RasterYuv420Semiplanar) -> This {
		result := This _create(rasterImage size, rasterImage stride, rasterImage y pointer, rasterImage uv pointer)
		result
	}
	create: func (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null) ? result : null
	}
	create2: static func ~empty (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null) ? result : null
	}
	_create: static /* internal */ func ~fromPixels (size: IntSize2D, stride: UInt, y: Pointer, uv: Pointer) -> This {
		result := This new(size)
		result _generate(stride, y, uv) ? result : null
	}

}
