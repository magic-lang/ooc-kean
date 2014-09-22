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

RasterMonochrome: class extends RasterPacked implements IDisposable {
	bytesPerPixel: Int { get { 1 } }
	init: func ~fromSize (size: IntSize2D) { this init(ByteBuffer new(RasterPacked calculateLength(size, 1)), size) }
	init: func ~fromStuff (size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(ByteBuffer new(RasterPacked calculateLength(size, 1)), size, coordinateSystem, crop)
	}
//	 FIXME but only if we really need it
//	init: func ~fromByteArray (data: UInt8*, size: IntSize2D) { this init(ByteBuffer new(data), size) }
	init: func ~fromIntPointer (pointer: UInt8*, size: IntSize2D) { this init(ByteBuffer new(size area * 1, pointer), size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, CoordinateSystem Default, IntShell2D new()) }
	init: func ~fromEverything (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(buffer, size, coordinateSystem, crop)
	}
	init: func ~fromRasterMonochrome (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) {
		this init(original size, original coordinateSystem, original crop)
//		"RasterMonochrome init ~fromRasterImage, original: (#{original size}), this: (#{this size}), stride #{this stride}" println()
		row := this pointer as UInt8*
		rowLength := this size width
		rowEnd := row + rowLength
		destination := row
		f := func (color: ColorMonochrome) {
			(destination as ColorMonochrome*)@ = color
//			"RasterMonochrome init ~fromRasterImage f, color: #{color y}, destination at #{destination}" println()
			destination += 1
			if (destination >= rowEnd) {
//				"RasterMonochrome init ~fromRasterImage f, end of line at #{destination}" println()
				row += this stride
				destination = row
//				"RasterMonochrome init ~fromRasterImage f, new line at #{destination}" println()
				rowEnd = row + rowLength
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
		this apply(ColorConvert fromMonochrome(action))
	}
	apply: func ~yuv (action: Func(ColorYuv)) {
		this apply(ColorConvert fromMonochrome(action))
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		end := (this pointer as UInt8*) + this length
		rowLength := this size width
		for (row in (this pointer as UInt8*)..end) {
//			"RasterMonochrome apply ~monochrome, end of line at #{row}" println()
			rowEnd := row + rowLength
			for (source in row..rowEnd)
				action((source as ColorMonochrome*)@)
			row += this stride-1
		}
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
					c := this[x,y]
					o := (other as RasterMonochrome)[x,y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - 2)..Int minimum(y + 3, this size height))
							for (otherX in Int maximum(0, x - 2)..Int minimum(x + 3, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as RasterMonochrome)[otherX, otherY]
									if (maximum y < pixel y)
										maximum y = pixel y;
									else if (minimum y > pixel y)
										minimum y = pixel y
								}
						distance := 0.0f;
						if (c y < minimum y)
							distance += (minimum y - c y) as Float squared()
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared()
						result += distance sqrt();
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
		requiredComponents := 1
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
	operator [] (x, y: Int) -> ColorMonochrome { this isValidIn(x, y) ? ((this pointer + y * this stride) as ColorMonochrome* + x)@ : ColorMonochrome new(0) }
	operator []= (x, y: Int, value: ColorMonochrome) { ((this pointer + y * this stride) as ColorMonochrome* + x)@ = value }
	dispose: func {
		this buffer dispose()
		free(buffer)
		free(this)
	}
}
