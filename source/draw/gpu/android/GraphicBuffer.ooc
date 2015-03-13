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
use ooc-base
use ooc-draw-gpu
import math
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
	_create: static Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
	_free: static Func (Pointer)
	_lock: static Func (Pointer, Bool, Pointer*)
	_unlock: static Func (Pointer)
	_alignedWidth: static Int[]


	_format: GraphicBufferFormat
	format ::= this _format
	_size: IntSize2D
	size ::= this _size
	_stride: Int
	stride ::= this _stride
	length: Int { get { this stride * this size height } }
	_backend: Pointer = null
	_nativeBuffer: Pointer = null
	nativeBuffer ::= this _nativeBuffer
	_handle: Pointer = null
	handle ::= this _handle
	_allocated := false

	init: func (=_size, =_format, usage: Int) {
		This _allocate(_size width, _size height, this _format as Int, usage, this _backend&, this _nativeBuffer&, this _stride&)
		this _allocated = true
	}
	init: func ~existing (=_backend, =_nativeBuffer, =_size, =_stride, =_format)
	init: func ~fromHandle (=_backend, =_nativeBuffer, =_handle, =_size, =_format, verticalAlign: Int, horizontalAlign: Int) {

	}
	free: override func {
		if (this _allocated)
			This _free(this _backend)
		super()
	}
	lock: func (write: Bool = false) -> Pointer {
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
	registerCallbacks: static func (allocate: Pointer, create: Pointer, free: Pointer, lock: Pointer, unlock: Pointer) {
		This _allocate = (allocate, null) as Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
		This _create = (create, null) as Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
		This _free = (free, null) as Func (Pointer)
		This _lock = (lock, null) as Func (Pointer, Bool, Pointer*)
		This _unlock = (unlock, null) as Func (Pointer)
	}
	configureAlignedWidth: static func (alignedWidth: Int*, count: Int) {
		This _alignedWidth = Int[count] new()
		for (i in 0..count)
			This _alignedWidth[i] = alignedWidth[i]
	}
	alignWidth: static func (width: Int, align := AlignWidth Nearest) -> Int {
		result := This _alignedWidth[0]
		match(align) {
			case AlignWidth Nearest => {
				for (i in 0..This _alignedWidth length) {
					currentWidth := This _alignedWidth[i]
					if (abs(result - width) > abs(currentWidth - width))
						result = currentWidth
				}
			}
			case AlignWidth Floor => {
				for (i in 0..This _alignedWidth length) {
					currentWidth := This _alignedWidth[i]
					if (abs(result - width) > abs(currentWidth - width) && currentWidth <= width)
						result = currentWidth
				}
			}
			case AlignWidth Ceiling => {
				result = This _alignedWidth[This _alignedWidth length-1]
				for (i in 0..This _alignedWidth length) {
					currentWidth := This _alignedWidth[i]
					if (abs(result - width) > abs(currentWidth - width) && currentWidth >= width)
						result = currentWidth
				}
			}
		}
		result
	}
	isAligned: static func (width: Int) -> Bool {
		result := false
		for (i in 0..This _alignedWidth length) {
			if (width == This _alignedWidth[i]) {
				result = true
				break
			}
		}
		result
	}

}
