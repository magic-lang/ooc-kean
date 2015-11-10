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
import io/File
import ByteBuffer into ByteBuffer
import math
import StbImage
import RasterImage
import RasterBgra
import RasterBgr
import RasterMonochrome
import Image

RasterPacked: abstract class extends RasterImage {
	_buffer: ByteBuffer
	buffer ::= this _buffer
	_stride: UInt
	stride ::= this _stride
	bytesPerPixel: Int { get }
	init: func (=_buffer, size: IntSize2D, =_stride) {
		super(size)
		this _buffer referenceCount increase()
	}
	init: func ~allocateStride (size: IntSize2D, stride: UInt) { this init(ByteBuffer new(stride * size height), size, stride) }
	init: func ~allocate (size: IntSize2D) {
		stride := this bytesPerPixel * size width
		this init(ByteBuffer new(stride * size height), size, stride)
	}
	init: func ~fromOriginal (original: This) {
		super(original)
		this _buffer = original buffer copy()
		this _stride = original stride
	}
	free: override func {
		if (this _buffer != null)
			this _buffer referenceCount decrease()
		this _buffer = null
		super()
	}
	equals: func (other: Image) -> Bool {
		other instanceOf?(This) && this bytesPerPixel == (other as This) bytesPerPixel && this as Image equals(other)
	}
	distance: virtual func (other: Image) -> Float {
		other instanceOf?(This) && this bytesPerPixel == (other as This) bytesPerPixel ? this as Image distance(other) : Float maximumValue
	}
	asRasterPacked: func (other: This) -> This {
		other
	}
	save: override func (filename: String) -> Int {
		file := File new(filename)
		folder := file parent . mkdirs() . free()
		file free()
		StbImage writePng(filename, this size width, this size height, this bytesPerPixel, this buffer pointer, this size width * this bytesPerPixel)
	}
	swapChannels: func (first, second: Int) {
		version(safe) {
			if (first > this bytesPerPixel || second > this bytesPerPixel)
				raise("Channel number too large")
		}
		pointer := this buffer pointer
		index := 0
		while (index < this buffer size) {
			value := pointer[index + first]
			pointer[index + first] = pointer[index + second]
			pointer[index + second] = value
			index += this bytesPerPixel
		}
	}
	kean_draw_rasterPacked_getData: unmangled func -> Void* { this buffer pointer }
}
