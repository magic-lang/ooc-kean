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
import math
import RasterPacked
import RasterImage
import StbImage
import Image
import Color

RasterBgra: class extends RasterPacked {
	bytesPerPixel: Int { get { 4 } }
	init: func ~allocate (size: IntSize2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntSize2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntSize2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { this init(buffer, size, this bytesPerPixel * size width) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this buffer copyTo(result buffer)
		result
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		end := this buffer pointer as Long + this buffer size
		rowLength := this size width * this bytesPerPixel
		for (row: Long in this buffer pointer as Long .. end) {
			rowEnd := row + rowLength
			for (source: Long in row .. rowEnd) {
				action((source as ColorBgr*)@)
				source += 3
			}
			row += this stride - 1
		}
	}
	apply: func ~yuv (action: Func(ColorYuv)) {
		this apply(ColorConvert fromBgr(action))
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromBgr(action))
	}
	distance: func (other: Image) -> Float {
		result := 0.0f
		if (!other)
			result = Float maximumValue
//		else if (!other instanceOf?(This))
//			FIXME
//		else if (this size != other size)
//			FIXME
		else {
			for (y in 0 .. this size height)
				for (x in 0 .. this size width) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum~two(0, y - this distanceRadius) .. Int minimum~two(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum~two(0, x - this distanceRadius) .. Int minimum~two(x + 1 + this distanceRadius, this size width))
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
									if (maximum alpha < pixel alpha)
										maximum alpha = pixel alpha
									else if (minimum alpha > pixel alpha)
										minimum alpha = pixel alpha
								}
						distance := 0.0f
						if (c blue < minimum blue)
							distance += (minimum blue - c blue) as Float squared()
						else if (c blue > maximum blue)
							distance += (c blue - maximum blue) as Float squared()
						if (c green < minimum green)
							distance += (minimum green - c green) as Float squared()
						else if (c green > maximum green)
							distance += (c green - maximum green) as Float squared()
						if (c red < minimum red)
							distance += (minimum red - c red) as Float squared()
						else if (c red > maximum red)
							distance += (c red - maximum red) as Float squared()
						if (c alpha < minimum alpha)
							distance += (minimum alpha - c alpha) as Float squared()
						else if (c alpha > maximum alpha)
							distance += (c alpha - maximum alpha) as Float squared()
						result += (distance) sqrt() / 4
					}
				}
			result /= ((this size width squared() + this size height squared()) as Float sqrt())
		}
	}
//	FIXME
//	openResource(assembly: ???, name: String) {
//		Image openResource
//	}
	open: static func (filename: String) -> This {
		x, y, n: Int
		requiredComponents := 4
		data := StbImage load(filename, x&, y&, n&, requiredComponents)
		buffer := ByteBuffer new(x * y * requiredComponents)
		// FIXME: Find a better way to do this using Dispose() or something
		memcpy(buffer pointer, data, x * y * requiredComponents)
		StbImage free(data)
		This new(buffer, IntSize2D new(x, y))
	}
	save: override func (filename: String) -> Int {
		StbImage writePng(filename, this size width, this size height, this bytesPerPixel, this buffer pointer, this size width * this bytesPerPixel)
	}
	convertFrom: static func (original: RasterImage) -> This {
		result := This new(original size)
		row := result buffer pointer as Long
		rowLength := result stride
		rowEnd := row + rowLength
		destination := row as ColorBgra*
		f := func (color: ColorBgr) {
			(destination as ColorBgra*)@ = ColorBgra new(color, 255)
			destination += 1
			if (destination >= rowEnd) {
				row += result stride
				destination = row as ColorBgra*
				rowEnd = row + rowLength
			}
		}
		original apply(f)
		result
	}
	operator [] (x, y: Int) -> ColorBgra { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorBgra* + x)@ : ColorBgra new(0, 0, 0, 0) }
	operator []= (x, y: Int, value: ColorBgra) { ((this buffer pointer + y * this stride) as ColorBgra* + x)@ = value }
	operator [] (point: IntPoint2D) -> ColorBgra { this[point x, point y] }
	operator []= (point: IntPoint2D, value: ColorBgra) { this[point x, point y] = value }
	operator [] (point: FloatPoint2D) -> ColorBgra { this [point x, point y] }
	operator [] (x, y: Float) -> ColorBgra {
		left := x - floor(x)
		top := y - floor(y)

		topLeft := this[floor(x) as Int, floor(y) as Int]
		bottomLeft := this[floor(x) as Int, ceil(y) as Int]
		topRight := this[ceil(x) as Int, floor(y) as Int]
		bottomRight := this[ceil(x) as Int, ceil(y) as Int]

		ColorBgra new(
			(top * (left * topLeft blue + (1 - left) * topRight blue) + (1 - top) * (left * bottomLeft blue + (1 - left) * bottomRight blue)),
			(top * (left * topLeft green + (1 - left) * topRight green) + (1 - top) * (left * bottomLeft green + (1 - left) * bottomRight green)),
			(top * (left * topLeft red + (1 - left) * topRight red) + (1 - top) * (left * bottomLeft red + (1 - left) * bottomRight red)),
			(top * (left * topLeft alpha + (1 - left) * topRight alpha) + (1 - top) * (left * bottomLeft alpha + (1 - left) * bottomRight alpha))
		)
	}
}
