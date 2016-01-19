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

use ooc-geometry
use base
use ooc-draw
use ooc-draw-gpu

version(!gpuOff) {
GraphicBufferFormat: enum {
	Rgba8888
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
	_format: GraphicBufferFormat
	_size: IntVector2D
	_pixelStride: Int
	_backend: Pointer = null
	_nativeBuffer: Pointer = null
	_handle: Pointer = null
	format ::= this _format
	size ::= this _size
	pixelStride ::= this _pixelStride
	stride: Int { get {
		match (this _format) {
			case GraphicBufferFormat Rgba8888 => this _pixelStride * 4
			case => this _pixelStride
		}
	}}
	length ::= this stride * this size y
	nativeBuffer ::= this _nativeBuffer
	handle ::= this _handle

	init: func (=_backend, =_nativeBuffer, =_handle, =_size, =_pixelStride, =_format)
	init: func ~allocate (size: IntVector2D, format: GraphicBufferFormat, usage: GraphicBufferUsage) {
		backend, nativeBuffer: Pointer
		pixelStride: Int
		This _allocate(size x, size y, format as Int, usage as Int, backend&, nativeBuffer&, pixelStride&)
		this init(backend, nativeBuffer, null, size, pixelStride, format)
	}
	free: override func {
		This _free(this _backend)
		super()
	}
	shallowCopy: func (size: IntVector2D, pixelStride: Int, format: GraphicBufferFormat, usage: GraphicBufferUsage) -> This {
		backend, nativeBuffer: Pointer
		This _createFromHandle(size x, size y, format as Int, usage as Int, pixelStride, this _handle, false, backend&, nativeBuffer&)
		This new(backend, nativeBuffer, handle, size, pixelStride, format)
	}
	lock: func (usage: GraphicBufferUsage) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, usage as Int, result&)
		result
	}
	unlock: func { This _unlock(this _backend) }
	_allocate: static Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
	_createFromHandle: static Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
	_free: static Func (Pointer)
	_lock: static Func (Pointer, Int, Pointer*)
	_unlock: static Func (Pointer)
	_alignedWidth: static Int[] = Int[0] new()
	alignWidth: static func (width: Int, align := AlignWidth Nearest) -> Int {
		result := width
		if (This _alignedWidth length > 0)
			result = align == AlignWidth Ceiling ? This _alignedWidth[This _alignedWidth length - 1] : This _alignedWidth[0]
		for (i in 0 .. This _alignedWidth length) {
			currentWidth := This _alignedWidth[i]
			if ((result - width) abs() > (currentWidth - width) abs() &&
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
	kean_draw_graphicBuffer_registerCallbacks: unmangled static func (allocate, createFromHandle, free, lock, unlock: Pointer) {
		This _allocate = (allocate, null) as Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
		This _createFromHandle = (createFromHandle, null) as Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
		This _free = (free, null) as Func (Pointer)
		This _lock = (lock, null) as Func (Pointer, Int, Pointer*)
		This _unlock = (unlock, null) as Func (Pointer)
	}
	kean_draw_graphicBuffer_configureAlignedWidth: unmangled static func (alignedWidth: Int*, count: Int) {
		This _alignedWidth = Int[count] new()
		memcpy(This _alignedWidth data, alignedWidth, count * Int size)
	}
	kean_draw_graphicBuffer_new: unmangled static func (backend, nativeBuffer, handle: Pointer, size: IntVector2D, pixelStride: Int, format: GraphicBufferFormat) -> This {
		This new(backend, nativeBuffer, handle, size, pixelStride, format)
	}
}
}
