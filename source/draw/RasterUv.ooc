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
import RasterBgr
import StbImage
import Image
import Color

RasterUv: class extends RasterPacked {
	bytesPerPixel: Int { get { 2 } }
	init: func ~allocate (size: IntSize2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntSize2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntSize2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { this init(buffer, size, this bytesPerPixel * size width) }
	init: func ~fromRasterImage (original: RasterImage) { super(original)	}
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this buffer copyTo(result buffer)
		result
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: func ~yuv (action: Func(ColorYuv)) {
		uvRow := this buffer pointer
		uSource := uvRow
		vRow := uvRow + 1
		vSource := vRow
		width := this size width
		height := this size height

		for (y in 0..height) {
			for (x in 0..width) {
				action(ColorYuv new(128, uSource@, vSource@))
				uSource += 2
				vSource += 2
			}
			uvRow += this stride
			uSource = uvRow
			vSource = uvRow + 1
		}
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
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
					o := (other as RasterUv)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum~two(0, y - this distanceRadius)..Int minimum~two(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum~two(0, x - this distanceRadius)..Int minimum~two(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as RasterUv)[otherX, otherY]
									if (maximum u < pixel u)
										maximum u = pixel u
									else if (minimum u > pixel u)
										minimum u = pixel u
									if (maximum v < pixel v)
										maximum v = pixel v
									else if (minimum v > pixel v)
										minimum v = pixel v
								}
						distance := 0.0f;
						if (c u < minimum u)
							distance += (minimum u - c u) as Float squared()
						else if (c u > maximum u)
							distance += (c u - maximum u) as Float squared()
						if (c v < minimum v)
							distance += (minimum v - c v) as Float squared()
						else if (c v > maximum v)
							distance += (c v - maximum v) as Float squared()
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
		This new(RasterBgr new(buffer, IntSize2D new (x, y)))
	}
	save: override func (filename: String) -> Int {
		result := RasterBgr new(this)
		StbImage writePng(filename, result size width, result size height, result bytesPerPixel, result buffer pointer, result size width * 3)
	}
	convertFrom: static func(original: RasterImage) -> This {
		result := This new(original)
		row := result buffer pointer
		rowLength := result size width
		rowEnd := row as ColorUv* + rowLength
		destination := row as ColorUv*
		f := func (color: ColorYuv) {
			(destination as ColorUv*)@ = ColorUv new(color u, color v)
			destination += 1
			if (destination >= rowEnd) {
				row += result stride
				destination = row as ColorUv*
				rowEnd = row as ColorUv* + rowLength
			}
		}
		original apply(f)
		result
	}

	operator [] (x, y: Int) -> ColorUv { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorUv* + x)@ : ColorUv new(0, 0) }
	operator []= (x, y: Int, value: ColorUv) { ((this buffer pointer + y * this stride) as ColorUv* + x)@ = value }
}
