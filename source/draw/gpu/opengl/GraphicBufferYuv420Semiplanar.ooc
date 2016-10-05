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
import GraphicBuffer

GraphicBufferYuv420Semiplanar: class extends RasterYuv420Semiplanar {
	_buffer: GraphicBuffer
	_stride: Int
	_uvOffset: Int
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
		this _buffer free()
		super()
	}
	copy: override func -> RasterYuv420Semiplanar {
		this buffer lock(GraphicBufferUsage ReadOften)
		result := super()
		this buffer unlock()
		result
	}
	copyFrom: override func (source: RasterYuv420Semiplanar) {
		this _buffer lock(GraphicBufferUsage WriteOften)
		super(source)
		this _buffer unlock()
	}
}
