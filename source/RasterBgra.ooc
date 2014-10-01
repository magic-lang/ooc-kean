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
import StbImage
import math
import structs/ArrayList
import RasterPacked
import RasterImage
import Image
import Color
import lang/IO

RasterBgra: class extends RasterPacked {
	bytesPerPixel: Int { get { 4 } }
	init: func ~fromSize (size: IntSize2D) { this init(ByteBuffer new(RasterPacked calculateLength(size, 4)), size) }
	init: func ~fromStuff (size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) { 
		super(ByteBuffer new(RasterPacked calculateLength(size, 4)), size, coordinateSystem, crop) 
	}
//	 FIXME but only if we really need it
//	init: func ~fromByteArray (data: UInt8*, size: IntSize2D) { this init(ByteBuffer new(data), size) }
	init: func ~fromIntPointer (pointer: UInt8*, size: IntSize2D) { this init(ByteBuffer new(size area * 4, pointer), size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, CoordinateSystem Default, IntShell2D new()) }
	init: func ~fromEverything (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(buffer, size, coordinateSystem, crop)
	}
	init: func ~fromRasterBgra (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) {
		this init(original size, original coordinateSystem, original crop)
		destination := this pointer as Int*
//		C#: original.Apply(color => *((Color.Bgra*)destination++) = new Color.Bgra(color, 255));
		f := func (color: ColorBgr) {
			(destination as ColorBgra*)@ = ColorBgra new(color, 255) 
			destination += 1
		}
		original apply(f)
	}
	create: func (size: IntSize2D) -> Image {
		result := This new(size)
		result crop = this crop
		result wrap = this wrap
		result
	}
	copy: func -> This {
		This new(this)
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		end := (this pointer as Int*) + this size area
		for (source in (this pointer as Int*)..end) {
			action((source as ColorBgr*)@)
			source +=3
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
					o := (other as RasterBgra)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - this distanceRadius)..Int minimum(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum(0, x - this distanceRadius)..Int minimum(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as RasterBgra)[otherX, otherY]
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
						if (c alpha < minimum alpha)
							distance += (minimum alpha - c alpha) as Float squared()
						else if (c alpha > maximum alpha)
							distance += (c alpha - maximum alpha) as Float squared()
						result += (distance) sqrt() / 4;
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
	save: func (filename: String) -> Int {
		StbImage writePng(filename, this size width, this size height, this bytesPerPixel, this buffer pointer, this size width * this bytesPerPixel)
	}
	operator [] (x, y: Int) -> ColorBgra { this isValidIn(x, y) ? ((this pointer + y * this stride) as ColorBgra* + x)@ : ColorBgra new(0, 0, 0, 0) }
	operator []= (x, y: Int, value: ColorBgra) { ((this pointer + y * this stride) as ColorBgra* + x)@ = value }
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
