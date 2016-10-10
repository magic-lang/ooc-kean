/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use draw

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
	_userData: Pointer = null
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

	init: func (=_backend, =_nativeBuffer, =_handle, =_size, =_pixelStride, =_format, =_userData)
	init: func ~allocate (size: IntVector2D, format: GraphicBufferFormat, usage: GraphicBufferUsage) {
		backend, nativeBuffer: Pointer
		pixelStride: Int
		This _allocate(size x, size y, format as Int, usage as Int, backend&, nativeBuffer&, pixelStride&)
		this init(backend, nativeBuffer, null, size, pixelStride, format, null)
	}
	free: override func {
		This _free(this _backend, this _userData)
		super()
	}
	shallowCopy: func (size: IntVector2D, pixelStride: Int, format: GraphicBufferFormat, usage: GraphicBufferUsage) -> This {
		backend, nativeBuffer: Pointer
		This _createFromHandle(size x, size y, format as Int, usage as Int, pixelStride, this _handle, false, backend&, nativeBuffer&)
		This new(backend, nativeBuffer, this handle, size, pixelStride, format, this _userData)
	}
	lock: func (usage: GraphicBufferUsage) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, usage as Int, result&)
		result
	}
	unlock: func { This _unlock(this _backend) }
	_allocate: static Func (Int, Int, Int, Int, Pointer*, Pointer*, Int*)
	_createFromHandle: static Func (Int, Int, Int, Int, Int, Pointer, Bool, Pointer*, Pointer*)
	_free: static Func (Pointer, Pointer)
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
}
