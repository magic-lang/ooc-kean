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
import ByteBuffer into ByteBuffer
import math
import structs/ArrayList
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
	init: func (=_buffer, size: IntSize2D, align := 0, verticalAlign := 0) {
		super(size, align, verticalAlign)
		this _buffer referenceCount increase()
		this _stride = Int align(this size width * bytesPerPixel, align)
	}
	init: func ~allocate (size: IntSize2D, align := 0, verticalAlign := 0) {
		this init(ByteBuffer new(Int align(size width * this bytesPerPixel, align) * size height), size, align, verticalAlign)
	}
	init: func ~fromOriginal (original: This) {
		super(original)
		this _stride = original stride
	}
	__destroy__: func {
		if (this _buffer != null)
			this _buffer referenceCount decrease()
		this _buffer = null
		super()
	}
	/*shift: func (offset: IntSize2D) -> Image {
		result: RasterImage
		if (this instanceOf?(RasterMonochrome))
			result = RasterMonochrome new(this size)
		else if (this instanceOf?(RasterBgr))
			result = RasterBgr new(this size)
		else if (this instanceOf?(RasterBgra))
			result = RasterBgra new(this size)
//		else if (this instanceOf?(RasterYuyv))
//			result = RasterYuyv new(this size)
		// FIXME: Use this line if and when Yuyv is implemented
//		offsetX := Int modulo(this instanceOf?(RasterYuyv) && Int modulo(offset width, 2) != 0 ? offset width + 1 : offset width, this size width)
		offsetX := Int modulo(offset width, this size width)
		length := (this size width - offsetX) * this bytesPerPixel
		line := this size width * this bytesPerPixel
		for (y in 0..this size height) {
			destination := Int modulo(y + offset height, this size height) * this stride
			result buffer copyFrom(this buffer, this stride * y, destination + offsetX * this bytesPerPixel, length)
			result buffer copyFrom(this buffer, this stride * y + length, destination, line - length)
		}
		result
	}*/
	equals: func (other: Image) -> Bool {
		other instanceOf?(This) && this bytesPerPixel == (other as RasterPacked) bytesPerPixel && this as Image equals(other)
	}
	distance: func (other: Image) -> Float {
		other instanceOf?(This) && this bytesPerPixel == (other as RasterPacked) bytesPerPixel ? this as Image distance(other) : Float maximumValue
	}
	asRasterPacked: func (other: This) -> This {
		other
	}
}
