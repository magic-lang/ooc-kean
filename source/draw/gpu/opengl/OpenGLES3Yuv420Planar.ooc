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
	canvas: GpuCanvas {
		get {
			if (this _canvas == null)
				this _canvas = OpenGLES3CanvasYuv420Planar create(this)
			this _canvas
		}
	}
	init: func (size: IntSize2D) { super(size) }
	dispose: func {
		if (this _canvas != null)
			this _canvas dispose()
		this _y dispose()
		this _u dispose()
		this _v dispose()
	}
	recycle: func {
		this _y recycle()
		this _u recycle()
		this _v recycle()
		this _canvas dispose()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _u bind(unit + 1)
		this _v bind(unit + 2)
	}
	_generate: func (stride: UInt, y: Pointer, u: Pointer, v: Pointer) -> Bool {
		this _y = OpenGLES3Monochrome _create(this size, stride, y)
		this _u = OpenGLES3Monochrome _create(this size / 2, stride, u)
		this _v = OpenGLES3Monochrome _create(this size / 2, stride, v)
		this _y != null && this _u != null && this _v != null
	}
	createStatic: static func ~fromRaster (rasterImage: RasterYuv420Planar) -> This {
		result := This _create(rasterImage size, rasterImage stride, rasterImage y pointer, rasterImage u pointer, rasterImage v pointer)
		result
	}
	create: func (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null, null) ? result : null
	}
	create2: static func ~empty (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null, null) ? result : null
	}
	_create: static /* internal */ func ~fromPixels (size: IntSize2D, stride: UInt, y: Pointer, u: Pointer, v: Pointer) -> This {
		result := This new(size)
		result _generate(stride, y, u, v) ? result : null
	}
}
