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

RasterBgra: class extends RasterPacked {
	get: func ~intPoint2D (point: IntPoint2D) -> ColorBgra { this get(point x, point y) }
	set: func ~intPoint2D (point: IntPoint2D, value: ColorBgra) { this set(point x, point y, color) }
	get: func ~ints (x, y: int) -> ColorBgra { ((this pointer + y * this stride) + x) as ColorBgra }
	set: func ~ints (x, y: int, color: ColorBgra) { ((this pointer + y * this stride) + x) as ColorBgra = value }
	get: func ~floatPoint2D (point: FloatPoint2D) -> ColorBgra { this get(point x, point y) }
	get: func ~floats (x, y: Float) {
		left := x - Int floor(x)
		top := y - Int floor(y)
		
		topLeft := this(Int floor(x), Int floor(y))
		bottomLeft := this(Int floor(x), Int ceiling(y))
		topRight := this(Int ceiling(x), Int floor(y))
		bottomRight := this(Int ceiling(x), Int floor(y))
		
		ColorBgra new(
			(top * (left * topLeft blue + (1 - left) * topRight blue) + (1 - top) * (left * bottomLeft blue + (1 - left) * bottomRight blue)),
			(top * (left * topLeft green + (1 - left) * topRight green) + (1 - top) * (left * bottomLeft green + (1 - left) * bottomRight green)),
			(top * (left * topLeft red + (1 - left) * topRight red) + (1 - top) * (left * bottomLeft red + (1 - left) * bottomRight red)),
			(top * (left * topLeft alpha + (1 - left) * topRight alpha) + (1 - top) * (left * bottomLeft alpha + (1 - left) * bottomRight alpha))
		)
	}
	bytesPerPixel: Int { get { 4 } }
	init: func (size: IntSize2D) { this init(ByteBuffer new(RasterPacked calculateLength(size, 4)), size) }
	init: func ~fromStuffer (size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) { 
		super(ByteBuffer new(RasterPacked calculateLength(size, 4)), size, coordinateSystem, crop) 
	}
	init: func ~fromByteArray (data: byte[], size: IntSize2D) { this init(ByteBuffer new(data), size) }
	init: func ~fromIntPointer (pointer: UInt8*, size: IntSize2D) { this init(ByteBuffer new(pointer, size area * 4), size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, CoordinateSystem default, IntShell2D new()) }
	init: func ~fromStuff (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(buffer, size, coordinateSystem, crop)
	}
	init: func ~fromRasterBgra (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { 
		this init(original size, original coordinateSystem, original crop)
		destination := this pointer as UInt8*
//		FIXME: How do I declare functions like this?
//		C#: original.Apply(color => *((Color.Bgra*)destination++) = new Color.Bgra(color, 255));
//		original apply(Func<color: ColorBgr> { destination++ as ColorBgra = ColorBgra new(color, 255) } )
	}
	create: func (size: IntSize2D) -> Image {
		result := Bgra new(size)
		result crop = this crop
		result wrap = this wrap
	}
	copy: func -> Image {
		Bgra new(this)
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
/*
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
				for (x in 0..this size width)
				{
					c := this get(x, y)
					o := other get(x, y)
					if (c distance(0) > 0)
					{
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - this distanceRadius)..Int minimum(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum(0, x - this distanceRadius)..Int minimum(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y)
								{
									pixel := other get(otherX, otherY)
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
									if (maximum Alpha < pixel Alpha)
										maximum Alpha = pixel Alpha
									else if (minimum Alpha > pixel Alpha)
										minimum Alpha = pixel Alpha
								}
						distance := 0.0f;
						if (c blue < minimum blue)
							distance += (minimum blue - c blue) pow(2.0f)
						else if (c blue > maximum blue)
							distance += (c blue - maximum blue) pow(2.0f)
						if (c green < minimum green)
							distance += (minimum green - c green) pow(2.0f)
						else if (c green > maximum green)
							distance += (c green - maximum green) pow(2.0f)
						if (c red < minimum red)
							distance += (minimum red - c red) pow(2.0f)
						else if (c red > maximum red)
							distance += (c red - maximum red) pow(2.0f)
						if (c alpha < minimum alpha)
							distance += (minimum alpha - c alpha) pow(2.0f)
						else if (c alpha > maximum alpha)
							distance += (c alpha - maximum alpha) pow(2.0f)
						result += (distance) sqrt() / 4;
					}
				}
			result /= this size length
		}
	}*/
//	FIXME
//	openResource(assembly: ???, name: String) {
//		Image openResource
//	}



}
