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
use ooc-draw
use ooc-draw-gpu
use ooc-base
use ooc-opengl
import math, AndroidTexture, AndroidContext

GpuPacker: class {
	_renderTarget: Fbo
	_targetTexture: AndroidRgba
	_context: AndroidContext
	_size: IntSize2D
	size: IntSize2D { get { this _size } }
	_internalSize: IntSize2D
	_bytesPerPixel: UInt
	bytesPerPixel: UInt { get { this _bytesPerPixel } }
	_packFence: Fence
	init: func (size: IntSize2D, bytesPerPixel: UInt, context: AndroidContext) {
		DebugPrint print("Allocating GpuPacker")
		this _packFence = Fence new()
		this _bytesPerPixel = bytesPerPixel
		this _context = context
		this _size = size
		this _internalSize = IntSize2D new(size width * bytesPerPixel / 4, size height)
		this _bytesPerPixel = bytesPerPixel
		this _targetTexture = context createAndroidRgba(this _internalSize, true, false)
		this _renderTarget = Fbo create(this _targetTexture backend, this _internalSize width, this _internalSize height)
	}
	recycle: func { this _context recycle(this) }
	free: func {
		this _targetTexture free()
		this _renderTarget free()
		super()
	}
	pack: func (image: GpuImage, map: OpenGLES3MapDefault) {
		image setMagFilter(false)
		this _renderTarget bind()
		this _renderTarget clear()
		surface := this _context createSurface()
		surface draw(image, map, Viewport new(this _internalSize))
		surface recycle()
		this _renderTarget unbind()
		image setMagFilter(true)
		this _packFence sync()
		This flush()
	}
	wait: func { this _packFence clientWait(1_000_000_000) }
	read: func ~ByteBuffer -> ByteBuffer {
		this wait()
		sourcePointer := this _targetTexture lock(false)
		buffer := ByteBuffer new(sourcePointer, this _targetTexture stride * this _targetTexture size height,
			func (buffer: ByteBuffer){
				this _targetTexture unlock()
				this recycle()
			})
		buffer
	}
	readRows: func ~ByteBuffer -> ByteBuffer {
		this wait()
		destinationWidth := this size width
		destinationHeight := this size height
		size := destinationWidth * destinationHeight * this bytesPerPixel
		buffer := ByteBuffer new(size)
		sourcePointer := this _targetTexture lock(false)
		sourceRow := sourcePointer
		sourceStride := this _targetTexture stride
		destinationRow := buffer pointer
		destinationStride := destinationWidth * this bytesPerPixel
		for (row in 0..destinationHeight) {
			sourceRow = sourcePointer + row * sourceStride
			destinationRow = buffer pointer + row * destinationStride
			memcpy(destinationRow, sourceRow, destinationStride)
		}
		this _targetTexture unlock()
		buffer
	}
	readRows: func ~overwrite (destination: RasterPacked) {
		this wait()
		sourcePointer := this _targetTexture lock(false)
		destinationPointer := destination buffer pointer
		destinationStride := destination stride
		sourceStride := this _targetTexture stride

		sourceRow := sourcePointer
		destinationRow := destinationPointer
		for(row in 0..destination size height) {
			sourceRow = sourcePointer + row * sourceStride
			destinationRow = destinationPointer + row * destinationStride
			memcpy(destinationRow, sourceRow, destinationStride)
		}
		this _targetTexture unlock()
	}
	read: func (destination: RasterPacked) {
		this wait()
		sourcePointer := this _targetTexture lock(false)
		destinationPointer := destination buffer pointer
		destinationStride := destination stride
		sourceStride := this _targetTexture stride
		memcpy(destinationPointer, sourcePointer, destinationStride * destination size height)
		this _targetTexture unlock()
	}
	finish: static func { Fbo finish() }
	flush: static func { Fbo flush() }
}
