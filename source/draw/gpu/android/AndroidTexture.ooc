//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-draw-gpu
use ooc-math
use ooc-opengl
use ooc-base
import GraphicBuffer

AndroidTexture: abstract class extends GpuTexture {
	backend: EGLImage { get { this _backend as EGLImage } }
	stride ::= this _buffer stride
	_channels: UInt
	_buffer: GraphicBuffer
	init: func (size: IntSize2D, =_buffer, eglImage: EGLImage, =_channels) {
		super(eglImage, size)
	}
	free: func {
		this backend free()
		this _buffer free()
	}
	lock: func (write: Bool) -> UInt8* { this _buffer lock(write) as UInt8* }
	unlock: func { this _buffer unlock() }
	setMagFilter: func (linear: Bool)
	upload: func (pixels: Pointer, stride: Int) {
		pointer := this _buffer lock(true)
		memcpy(pointer, pixels, this size width * this size height * this _channels)
		this _buffer unlock()
	}
	generateMipmap: func { raise("generateMipmap unimplemented for Android Texture!") }
	bind: func (unit: UInt) { this backend bind(unit) }
	unbind: func { this backend unbind() }
}

AndroidRgba: class extends AndroidTexture {
	init: func ~allocate (size: IntSize2D, read: Bool, write: Bool, eglDisplay: Pointer) {
		gb := GraphicBuffer new(size, GraphicBufferFormat Rgba8888, GraphicBuffer getUsageFlags(read, write))
		egl := EGLImage create(TextureType rgba, size width, size height, gb nativeBuffer, eglDisplay)
		super(size, gb, egl, 4)
	}
	init: func ~fromGraphicBuffer (buffer: GraphicBuffer, eglDisplay: Pointer) {
		eglImage := EGLImage create(TextureType rgba, buffer size width, buffer size height, buffer nativeBuffer, eglDisplay)
		super(IntSize2D new(eglImage width, eglImage height), buffer, eglImage, 4)
	}
}

AndroidYv12: class extends AndroidTexture {
	init: func ~allocate (size: IntSize2D, read: Bool, write: Bool, eglDisplay: Pointer) {
		gb := GraphicBuffer new(size, GraphicBufferFormat Yv12, GraphicBuffer getUsageFlags(read, write))
		super(size, gb, EGLImage create(TextureType rgba, size width, size height, gb nativeBuffer, eglDisplay), 1)
	}
	init: func ~fromGraphicBuffer (buffer: GraphicBuffer, eglDisplay: Pointer) {
		eglImage := EGLImage create(TextureType yv12, buffer size width, buffer size height, buffer nativeBuffer, eglDisplay)
		super(IntSize2D new(eglImage width, eglImage height), buffer, eglImage, 1)
	}
}
