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
	init: func ~fromIntPointer (pointer: UInt8*, size: IntSize2D) { this init(ByteBuffer new(size Area * 4, pointer), size) }
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
	copy: func -> Image {
		This new(this)
	}
	apply: func ~bgr (action: Func<ColorBgr>) {
//		FIXME
	}
	apply: func ~yuv (action: Func<ColorYuv>) {
//		FIXME
	}
	apply: func ~monochrome (action: Func<ColorMonochrome>) {
//		FIXME			
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
									if (maximum Blue < pixel Blue)
										maximum Blue = pixel Blue
									else if (minimum Blue > pixel Blue)
										minimum Blue = pixel Blue
									if (maximum Green < pixel Green)
										maximum Green = pixel Green
									else if (minimum Green > pixel Green)
										minimum Green = pixel Green
									if (maximum Red < pixel Red)
										maximum Red = pixel Red
									else if (minimum Red > pixel Red)
										minimum Red = pixel Red
									if (maximum alpha < pixel alpha)
										maximum alpha = pixel alpha
									else if (minimum alpha > pixel alpha)
										minimum alpha = pixel alpha
								}
						distance := 0.0f;
						if (c Blue < minimum Blue)
							distance += (minimum Blue - c Blue) as Float squared()
						else if (c Blue > maximum Blue)
							distance += (c Blue - maximum Blue) as Float squared()
						if (c Green < minimum Green)
							distance += (minimum Green - c Green) as Float squared()
						else if (c Green > maximum Green)
							distance += (c Green - maximum Green) as Float squared()
						if (c Red < minimum Red)
							distance += (minimum Red - c Red) as Float squared()
						else if (c Red > maximum Red)
							distance += (c Red - maximum Red) as Float squared()
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
			(top * (left * topLeft Blue + (1 - left) * topRight Blue) + (1 - top) * (left * bottomLeft Blue + (1 - left) * bottomRight Blue)),
			(top * (left * topLeft Green + (1 - left) * topRight Green) + (1 - top) * (left * bottomLeft Green + (1 - left) * bottomRight Green)),
			(top * (left * topLeft Red + (1 - left) * topRight Red) + (1 - top) * (left * bottomLeft Red + (1 - left) * bottomRight Red)),
			(top * (left * topLeft alpha + (1 - left) * topRight alpha) + (1 - top) * (left * bottomLeft alpha + (1 - left) * bottomRight alpha))
		)
	}
}
