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
use ooc-math
GraphicBufferFormat: enum {
	Rgba8888 = 1
	Yv12
}
GraphicBufferUsage: enum (*2) {
	ReadNever = 1
	ReadOften
	WriteNever
	WriteOften
	Texture
	Rendertarget
}
GraphicBuffer: class {
	_allocate: static Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
	_free: static Func (Pointer)
	_lock: static Func (Pointer, Bool, Pointer*)
	_unlock: static Func (Pointer)
	_format: GraphicBufferFormat
	format ::= this _format
	_size: IntSize2D
	size ::= this _size
	_stride: Int
	stride ::= this _stride
	_backend: Pointer = null
	_nativeBuffer: Pointer = null
	nativeBuffer ::= this _nativeBuffer
	_allocated := false
	init: func (=_size, =_format, usage: Int) {
		This _allocate(_size width, _size height, this _format as Int, usage, this _backend&, this _nativeBuffer&, this _stride&)
		this _allocated = true
	}
	init: func ~existing (=_backend, =_nativeBuffer, =_size, =_stride, =_format)
	free: func {
		if (this _allocated)
			This _free(this _backend)
		super()
	}
	lock: func (write: Bool) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, write, result&)
		result
	}
	unlock: func { This _unlock(this _backend) }
	getUsageFlags: static func (read: Bool, write: Bool) -> Int {
		usage := 0
		usage = read ? usage | GraphicBufferUsage ReadOften : usage | GraphicBufferUsage ReadNever
		usage = write ? usage | GraphicBufferUsage WriteOften : usage | GraphicBufferUsage WriteNever
		usage
	}
	initialize: static func (allocate: Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*), free: Func (Pointer),
	lock: Func (Pointer, Bool, Pointer*), unlock: Func (Pointer)) {
		This _allocate = allocate
		This _free = free
		This _lock = lock
		This _unlock = unlock
	}
}
