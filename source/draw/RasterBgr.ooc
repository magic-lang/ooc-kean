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
use ooc-base
import RasterPacked
import RasterImage
import StbImage
import Image
import Color
import Canvas, Brush, RasterCanvas

RasterBgrCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterBgr
	init: func (image: RasterBgr) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toBgr())
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		bgr: RasterBgr = null
		if (image instanceOf?(RasterBgr))
			bgr = image as RasterBgr
		else if (image instanceOf?(RasterImage))
			bgr = RasterBgr convertFrom(image as RasterImage)
		else
			Debug raise("Unsupported image type in BgrRasterCanvas draw")
		this _resizePacked(bgr buffer pointer as ColorBgr*, bgr, source, destination)
		if (bgr != image)
			bgr referenceCount decrease()
	}
}

RasterBgr: class extends RasterPacked {
	bytesPerPixel ::= 3
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterBgr (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~bgr (action: Func(ColorBgr)) {
		for (row in 0 .. this size y)
			for (pixel in 0 .. this size x) {
				pointer := this buffer pointer + pixel * this bytesPerPixel + row * this stride
				color := (pointer as ColorBgr*)@
				action(color)
			}
	}
	apply: override func ~yuv (action: Func(ColorYuv)) {
		convert := ColorConvert fromBgr(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		convert := ColorConvert fromBgr(action)
		this apply(convert)
		(convert as Closure) free()
	}
	resizeTo: override func (size: IntVector2D) -> This {
		result := This new(size)
		result canvas draw(this, IntBox2D new(this size), IntBox2D new(size))
		result
	}
	distance: func (other: Image) -> Float {
		result := 0.0f
		if (!other || (this size != other size))
			result = Float maximumValue
		else if (!other instanceOf?(This)) {
			converted := This convertFrom(other as RasterImage)
			result = this distance(converted)
			converted referenceCount decrease()
		} else {
			for (y in 0 .. this size y)
				for (x in 0 .. this size x) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in 0 maximum(y - this distanceRadius) .. (y + 1 + this distanceRadius) minimum(this size y))
							for (otherX in 0 maximum(x - this distanceRadius) .. (x + 1 + this distanceRadius) minimum(this size x))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
									if (maximum blue < pixel blue)
										maximum blue = pixel blue
									else if (minimum blue > pixel blue)
										minimum blue = pixel blue
									if (maximum green < pixel green)
										maximum green = pixel green
									else if (minimum green > pixel green)
										minimum green = pixel green
									if (maximum red < pixel red)
										maximum red = pixel red
									else if (minimum red > pixel red)
										minimum red = pixel red
								}
						distance := 0.0f
						if (c blue < minimum blue)
							distance += (minimum blue - c blue) as Float squared
						else if (c blue > maximum blue)
							distance += (c blue - maximum blue) as Float squared
						if (c green < minimum green)
							distance += (minimum green - c green) as Float squared
						else if (c green > maximum green)
							distance += (c green - maximum green) as Float squared
						if (c red < minimum red)
							distance += (minimum red - c red) as Float squared
						else if (c red > maximum red)
							distance += (c red - maximum red) as Float squared
						result += (distance) sqrt() / 3
					}
				}
			result /= this size length
		}
		result
	}
	swapRedBlue: func {
		this swapChannels(0, 2)
	}
	redBlueSwapped: func -> This {
		result := this copy()
		result swapRedBlue()
		result
	}
	_createCanvas: override func -> Canvas { RasterBgrCanvas new(this) }

	operator [] (x, y: Int) -> ColorBgr { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorBgr* + x)@ : ColorBgr new(0, 0, 0) }
	operator []= (x, y: Int, value: ColorBgr) { ((this buffer pointer + y * this stride) as ColorBgr* + x)@ = value }

	open: static func (filename: String) -> This {
		x, y, imageComponents: Int
		requiredComponents := 3
		data := StbImage load(filename, x&, y&, imageComponents&, requiredComponents)
		buffer := ByteBuffer new(data as UInt8*, x * y * requiredComponents, true)
		This new(buffer, IntVector2D new(x, y))
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf?(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			row := result buffer pointer as Long
			rowLength := result size x
			rowEnd := row as ColorBgr* + rowLength
			destination := row as ColorBgr*
			f := func (color: ColorBgr) {
				(destination as ColorBgr*)@ = color
				destination += 1
				if (destination >= rowEnd) {
					row += result stride
					destination = row as ColorBgr*
					rowEnd = row as ColorBgr* + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	kean_draw_rasterBgr_new: static unmangled func (width, height, stride: Int, data: Void*) -> This {
		result := This new(IntVector2D new(width, height), stride)
		memcpy(result buffer pointer, data, height * stride)
		result
	}
}
