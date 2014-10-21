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
import OpenGLES3/Texture, OpenGLES3Canvas

OpenGLES3Bgr: class extends GpuBgr {
	canvas: GpuCanvas {
		 get {
			if (this _canvas == null)
				this _canvas = OpenGLES3Canvas create(this)
			this _canvas
		}
	}
	backend: Texture { get { this _backend as Texture } }
	init: func (size: IntSize2D) {
		init(size, size width, null)
	}
	init: func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer) {
		super(size)
		this _backend = Texture create(TextureType bgr, size width, size height, stride, data) as Pointer
	}
	createStatic: static func ~fromRaster (rasterImage: RasterBgr) -> This {
		result := This new(rasterImage size, rasterImage stride, rasterImage pointer)
		result
	}
	create: func (size: IntSize2D) -> This {
		result := This new(size)
		result backend != null ? result : null
	}
	create2: static func ~empty (size: IntSize2D) -> This {
		result := This new(size)
		result backend != null ? result : null
	}
	_create: static /* internal */ func ~fromPixels (size: IntSize2D, stride: UInt, data: Pointer) -> This {
		result := This new(size, stride, data)
		result backend != null ? result : null
	}
	replace: func (image: RasterBgra) {
		this backend uploadPixels(image pointer)
	}
	bind: func (unit: UInt) {
		this backend bind (unit)
	}
	dispose: func {
		this backend dispose()
		if (this _canvas != null)
			this _canvas dispose()
	}
	recycle: func {
		this backend recycle()
	}
	generateMipmap: func {
		this backend generateMipmap()
	}
}
