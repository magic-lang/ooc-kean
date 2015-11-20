/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
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

import math
use ooc-draw
use ooc-math
use ooc-base
use ooc-draw-gpu
import GraphicBuffer, AndroidContext, EGLBgra

version(!gpuOff) {
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	_stride: Int
	stride ::= this _stride
	_uvOffset: Int
	uvOffset ::= this _uvOffset
	uvPadding ::= (this _uvOffset - this _stride * this _size y)
	init: func ~fromBuffer (=_buffer, size: IntVector2D, =_stride, =_uvOffset) {
		pointer := _buffer lock()
		_buffer unlock()
		length := 3 * this _stride * size y / 2
		super(ByteBuffer new(pointer, length), size, _stride, _uvOffset)
	}
	init: func (backend: Pointer, nativeBuffer: Pointer, handle: Pointer, size: IntVector2D, format: GraphicBufferFormat, stride: Int, uvOffset: Int) {
		this init(GraphicBuffer new(backend, nativeBuffer, handle, size, stride, format), size, stride, uvOffset)
	}
	free: override func {
		this _buffer free()
		super()
	}
	toRgba: func (context: AndroidContext) -> GpuImage {
		padding := this _uvOffset - this _stride * this _size y
		extraRows := Int align(padding, this _stride) / this _stride
		height := this _size y + this _size y / 2 + extraRows
		width := this _stride / 4
		rgbaBuffer := GraphicBuffer new(this buffer handle, IntVector2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget)
		result := EGLBgra new(rgbaBuffer, context)
		result coordinateSystem = this coordinateSystem
		result
	}
	kean_draw_graphicBufferYuv420Semiplanar_new: unmangled static func (backend, nativeBuffer, handle: Pointer, size: IntVector2D, stride: Int, format: GraphicBufferFormat, uvOffset: Int) -> This {
		This new(backend, nativeBuffer, handle, size, format, stride, uvOffset)
	}
}
}
