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

use ooc-draw
use ooc-geometry
use ooc-base
use ooc-collections
use ooc-draw-gpu
import GraphicBuffer, AndroidContext, EGLBgra
import threading/Mutex

version(!gpuOff) {
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	_stride: Int
	_uvOffset: Int
	_rgba: EGLBgra = null
	buffer ::= this _buffer
	stride ::= this _stride
	uvOffset ::= this _uvOffset
	uvPadding ::= (this _uvOffset - this _stride * this _size y)
	init: func ~fromBuffer (=_buffer, size: IntVector2D, =_stride, =_uvOffset) {
		pointer := _buffer lock(GraphicBufferUsage ReadOften)
		_buffer unlock()
		length := 3 * this _stride * size y / 2
		super(ByteBuffer new(pointer, length), size, _stride, _uvOffset)
	}
	free: override func {
		if (this _rgba != null)
			This _recycle(this _rgba)
		this _buffer free()
		super()
	}
	toRgba: func (context: AndroidContext) -> GpuImage {
		if (this _rgba == null)
			this _rgba = This _search(this _buffer)
		if (this _rgba == null) {
			padding := this _uvOffset - this _stride * this _size y
			extraRows := padding align(this _stride) / this _stride
			height := this _size y + this _size y / 2 + extraRows
			width := this _stride / 4
			rgbaBuffer := this buffer shallowCopy(IntVector2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget)
			this _rgba = EGLBgra new(rgbaBuffer, context)
			this _rgba referenceCount increase()
		}
		this _rgba _coordinateSystem = this coordinateSystem
		this _rgba referenceCount increase()
		this _rgba
	}
	_bin := static VectorList<EGLBgra> new()
	_mutex := static Mutex new()
	_binSize: static Int = 100
	_recycle: static func (image: EGLBgra) {
		This _mutex lock()
		This _bin add(image)
		if (This _bin count > This _binSize)
			This _bin remove(0) referenceCount decrease()
		This _mutex unlock()
	}
	_search: static func (buffer: GraphicBuffer) -> EGLBgra {
		This _mutex lock()
		result: EGLBgra = null
		for (i in 0 .. This _bin count) {
			if (This _bin[i] buffer _handle == buffer _handle) {
				result = This _bin remove(i)
				break
			}
		}
		This _mutex unlock()
		result
	}
	free: static func ~all {
		This _mutex lock()
		while (!This _bin empty)
			This _bin remove() referenceCount decrease()
		This _mutex unlock()
	}
	kean_draw_graphicBufferYuv420Semiplanar_new: unmangled static func (buffer: GraphicBuffer, size: IntVector2D, stride, uvOffset: Int) -> This { This new(buffer, size, stride, uvOffset) }
}
}
