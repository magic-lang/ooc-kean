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
EglRgba: class extends GpuTexture {
	backend: EGLImage { get { this _backend as EGLImage } }
	stride ::= this _buffer stride
	_channels := 4
	_buffer: GraphicBuffer
	init: func (=_size, read: Bool, write: Bool, eglDisplay: Pointer) {
		usage := 0
		usage = read ? usage | GraphicBufferUsage ReadOften : usage | GraphicBufferUsage ReadNever
		usage = write ? usage | GraphicBufferUsage WriteOften : usage | GraphicBufferUsage WriteNever
		this _buffer = GraphicBuffer new(_size, usage)
		super(EGLImage create(TextureType rgba, _size width, _size height, this _buffer nativeBuffer, eglDisplay), _size)
		DebugPrint print("Allocating EGL Image")
	}
	init: func ~fromGraphicBuffer (=_buffer, eglDisplay: Pointer) {
		eglImage := EGLImage create(TextureType rgba, _buffer size width, _buffer size height, _buffer nativeBuffer, eglDisplay)
		super(eglImage, IntSize2D new(eglImage width, eglImage height))
	}
	dispose: func {
		this backend dispose()
		this _buffer free()
	}
	lock: func (write: Bool) -> UInt8* {
		this _buffer lock(write) as UInt8*
	}
	unlock: func {
		this _buffer unlock()
	}
	setMagFilter: func (linear: Bool)
	upload: func (pixels: Pointer, stride: Int) {
		pointer := this _buffer lock(true)
		memcpy(pointer, pixels, this size width * this size height * this _channels)
		this _buffer unlock()
	}
	generateMipmap: func { raise("Unimplemented") }
	bind: func (unit: UInt) { this backend bind(unit) }
	unbind: func { this backend unbind() }
}
