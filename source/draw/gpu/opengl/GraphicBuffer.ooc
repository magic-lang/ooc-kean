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
use ooc-draw
use ooc-draw-gpu
import math

version(!gpuOff) {
GraphicBufferFormat: enum {
	Rgba8888 = 1
	Yv12
}
GraphicBufferUsage: enum (*2) {
	ReadNever = 1
	ReadRarely
	ReadOften
	ReadMask
	WriteNever
	WriteRarely
	WriteOften
	WriteMask
	Texture
	RenderTarget
}

GraphicBuffer: class {
	_allocate: static Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
	_create: static Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
	_free: static Func (Pointer)
	_lock: static Func (Pointer, Int, Pointer*)
	_unlock: static Func (Pointer)
	_alignedWidth: static Int[] = Int[0] new()
	_format: GraphicBufferFormat
	format ::= this _format
	_size: IntSize2D
	size ::= this _size
	_pixelStride: Int
	pixelStride ::= this _pixelStride
	stride: Int {
		get {
			match (this _format) {
				case GraphicBufferFormat Rgba8888 => this _pixelStride * 4
				case => this _pixelStride
			}
		}
	}
	length ::= this stride * this size height
	_backend: Pointer = null
	_nativeBuffer: Pointer = null
	nativeBuffer ::= this _nativeBuffer
	_handle: Pointer = null
	handle ::= this _handle
	_allocated := false

	init: func (=_size, =_format, usage: GraphicBufferUsage) {
		This _allocate(_size width, _size height, this _format as Int, usage as Int, this _backend&, this _nativeBuffer&, this _pixelStride&)
		this _allocated = true
	}
	init: func ~existing (=_backend, =_nativeBuffer, =_handle, =_size, =_pixelStride, =_format)
	init: func ~fromHandle (handle: Pointer, =_size, =_pixelStride, =_format, usage: GraphicBufferUsage) {
		This _create(_size width, _size height, _format as Int, usage as Int, _pixelStride, handle, false, this _backend&, this _nativeBuffer&)
	}
	free: override func {
		if (this _allocated)
			This _free(this _backend)
		super()
	}
	lock: func (write := false) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, write ? (GraphicBufferUsage WriteOften) as Int: (GraphicBufferUsage ReadOften) as Int, result&)
		result
	}
	lock: func ~withUsage (usage: GraphicBufferUsage) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, usage as Int, result&)
		result
	}
	unlock: func { This _unlock(this _backend) }
	kean_draw_gpu_android_graphicBuffer_registerCallbacks: unmangled static func (allocate, create, free, lock, unlock: Pointer) {
		This _allocate = (allocate, null) as Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
		This _create = (create, null) as Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
		This _free = (free, null) as Func (Pointer)
		This _lock = (lock, null) as Func (Pointer, Int, Pointer*)
		This _unlock = (unlock, null) as Func (Pointer)
	}
	kean_draw_gpu_android_graphicBuffer_configureAlignedWidth: unmangled static func (alignedWidth: Int*, count: Int) {
		This _alignedWidth = Int[count] new()
		memcpy(This _alignedWidth data, alignedWidth, count * Int size)
	}
	alignWidth: static func (width: Int, align := AlignWidth Nearest) -> Int {
		result := width
		if (This _alignedWidth length > 0)
			result = align == AlignWidth Ceiling ? This _alignedWidth[This _alignedWidth length-1] : This _alignedWidth[0]
		for (i in 0 .. This _alignedWidth length) {
			currentWidth := This _alignedWidth[i]
			if (abs(result - width) > abs(currentWidth - width) &&
				(align == AlignWidth Nearest ||
				(currentWidth <= width && align == AlignWidth Floor) ||
				(currentWidth >= width && align == AlignWidth Ceiling)))
				result = currentWidth
		}
		result
	}
	isAligned: static func (width: Int) -> Bool {
		result := false
		for (i in 0 .. This _alignedWidth length) {
			if (width == This _alignedWidth[i]) {
				result = true
				break
			}
		}
		result
	}
}
}
