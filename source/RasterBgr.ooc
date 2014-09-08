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
import structs/ArrayList
import RasterPacked
import RasterImage
import StbImage
import Image
import Color

RasterBgr: class extends RasterPacked implements IDisposable {
	bytesPerPixel: Int { get { 3 } }
	init: func ~fromSize (size: IntSize2D) { this init(ByteBuffer new(RasterPacked calculateLength(size, 3)), size) }
	init: func ~fromStuff (size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(ByteBuffer new(RasterPacked calculateLength(size, 3)), size, coordinateSystem, crop)
	}
//	 FIXME but only if we really need it
//	init: func ~fromByteArray (data: UInt8*, size: IntSize2D) { this init(ByteBuffer new(data), size) }
	init: func ~fromIntPointer (pointer: UInt8*, size: IntSize2D) { this init(ByteBuffer new(size area * 3, pointer), size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, CoordinateSystem Default, IntShell2D new()) }
	init: func ~fromEverything (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(buffer, size, coordinateSystem, crop)
	}
	init: func ~fromRasterBgra (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) {
		this init(original size, original coordinateSystem, original crop)
		row := this pointer as UInt8*
		rowLength := this size width
		rowEnd := row as ColorBgr* + rowLength
		destination := row as ColorBgr*
		f := func (color: ColorBgr) {
			(destination as ColorBgr*)@ = color
			destination += 1
			if (destination >= rowEnd) {
				row += this stride
				destination = row as ColorBgr*
				rowEnd = row as ColorBgr* + rowLength
			}
		}
		original apply(f)
	}
	create: func (size: IntSize2D) -> Image {
		result := This new(size)
		result crop = this crop
		result wrap = this wrap
		result
	}
	copy: func -> Image {
		This new(this)
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		end := (this pointer as UInt8*) + this length
		rowLength := this size width
		for (row in (this pointer as UInt8*)..end) {
			rowEnd := (row as ColorBgr*) + rowLength
			for (source in (row as ColorBgr*)..rowEnd) {
				action((source as ColorBgr*)@)
				source += 2
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
			for (y in 0..this size height)
				for (x in 0..this size width) {
					c := this[x, y]
					o := (other as RasterBgr)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - this distanceRadius)..Int minimum(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum(0, x - this distanceRadius)..Int minimum(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as RasterBgr)[otherX, otherY]
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
						distance := 0.0f;
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
						result += (distance) sqrt() / 3;
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
		requiredComponents := 3
		data := StbImage load(filename, x&, y&, n&, requiredComponents)
		buffer := ByteBuffer new(x * y * requiredComponents)
		// FIXME: Find a better way to do this using Dispose() or something
		memcpy(buffer pointer, data, x * y * requiredComponents)
		StbImage free(data)
		This new(buffer, IntSize2D new(x, y))
	}
	save: func (filename: String) -> Int {
		StbImage writePng(filename, this size width, this size height, this bytesPerPixel, this buffer pointer, this size width * 3)
	}
	operator [] (x, y: Int) -> ColorBgr { this isValidIn(x, y) ? ((this pointer + y * this stride) as ColorBgr* + x)@ : ColorBgr new(0, 0, 0) }
	operator []= (x, y: Int, value: ColorBgr) { ((this pointer + y * this stride) as ColorBgr* + x)@ = value }
	dispose: func
}
