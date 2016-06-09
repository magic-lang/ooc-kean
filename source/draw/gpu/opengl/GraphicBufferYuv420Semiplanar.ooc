/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use geometry
use base
use draw-gpu
use concurrent
import GraphicBuffer, OpenGLContext, EGLRgba

version(!gpuOff) {
GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	_stride: Int
	_uvOffset: Int
	_rgba: EGLRgba = null
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
			This _bin add(this _rgba)
		this _buffer free()
		super()
	}
	toRgba: func (context: OpenGLContext) -> GpuImage {
		if (this _rgba == null)
			this _rgba = This _bin search(|image| this buffer _handle == image buffer _handle)
		if (this _rgba == null) {
			padding := this _uvOffset - this _stride * this _size y
			extraRows := padding align(this _stride) / this _stride
			height := this _size y + this _size y / 2 + extraRows
			width := this _stride / 4
			rgbaBuffer := this buffer shallowCopy(IntVector2D new(width, height), width, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget)
			this _rgba = EGLRgba new(rgbaBuffer, context)
			this _rgba referenceCount increase()
		}
		this _rgba referenceCount increase()
		this _rgba
	}
	copy: override func -> RasterYuv420Semiplanar {
		this buffer lock(GraphicBufferUsage ReadOften)
		result := super()
		this buffer unlock()
		result
	}
	_bin := static RecycleBin<EGLRgba> new(100, |image| image referenceCount decrease())
	free: static func ~all { This _bin clear() }
}

GlobalCleanup register(|| GraphicBufferYuv420Semiplanar free~all())
}
