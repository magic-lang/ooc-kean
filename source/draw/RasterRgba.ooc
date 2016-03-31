/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import RasterPacked
import RasterImage
import io/File
import StbImage
import Image
import Color
import Pen
import Canvas, RasterCanvas

RasterRgbaCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterRgba
	init: func (image: RasterRgba) { super(image) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(pen alphaAsFloat, pen color)
	}
}

RasterRgba: class extends RasterPacked {
	bytesPerPixel ::= 4
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt, coordinateSystem := CoordinateSystem Default) { super(buffer, size, stride, coordinateSystem) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D, coordinateSystem := CoordinateSystem Default) { this init(buffer, size, this bytesPerPixel * size x, coordinateSystem) }
	init: func ~fromRasterRgba (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		for (row in 0 .. this size y) {
			source := this buffer pointer + row * this stride
			for (pixel in 0 .. this size x) {
				pixelPointer := (source + pixel * this bytesPerPixel)
				color := (pixelPointer as ColorRgb*)@
				action(color)
			}
		}
	}
	apply: override func ~yuv (action: Func(ColorYuv)) {
		convert := ColorConvert fromRgb(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		convert := ColorConvert fromRgb(action)
		this apply(convert)
		(convert as Closure) free()
	}
	distance: func (other: Image) -> Float {
		result := 0.0f
		if (!other || (this size != other size))
			result = Float maximumValue
		else if (!other instanceOf(This)) {
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
									if (maximum b < pixel b)
										maximum b = pixel b
									else if (minimum b > pixel b)
										minimum b = pixel b
									if (maximum g < pixel g)
										maximum g = pixel g
									else if (minimum g > pixel g)
										minimum g = pixel g
									if (maximum r < pixel r)
										maximum r = pixel r
									else if (minimum r > pixel r)
										minimum r = pixel r
									if (maximum a < pixel a)
										maximum a = pixel a
									else if (minimum a > pixel a)
										minimum a = pixel a
								}
						distance := 0.0f
						if (c b < minimum b)
							distance += (minimum b - c b) as Float squared
						else if (c b > maximum b)
							distance += (c b - maximum b) as Float squared
						if (c g < minimum g)
							distance += (minimum g - c g) as Float squared
						else if (c g > maximum g)
							distance += (c g - maximum g) as Float squared
						if (c r < minimum r)
							distance += (minimum r - c r) as Float squared
						else if (c r > maximum r)
							distance += (c r - maximum r) as Float squared
						if (c a < minimum a)
							distance += (minimum a - c a) as Float squared
						else if (c a > maximum a)
							distance += (c a - maximum a) as Float squared
						result += (distance) sqrt() / 4
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
	_createCanvas: override func -> Canvas { RasterRgbaCanvas new(this) }

	operator [] (x, y: Int) -> ColorRgba { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorRgba* + x)@ : ColorRgba new(0, 0, 0, 0) }
	operator []= (x, y: Int, value: ColorRgba) { ((this buffer pointer + y * this stride) as ColorRgba* + x)@ = value }
	operator [] (point: IntPoint2D) -> ColorRgba { this[point x, point y] }
	operator []= (point: IntPoint2D, value: ColorRgba) { this[point x, point y] = value }
	operator [] (point: FloatPoint2D) -> ColorRgba { this [point x, point y] }
	operator [] (x, y: Float) -> ColorRgba {
		left := x - x floor()
		top := y - y floor()

		topLeft := this[x floor() as Int, y floor() as Int]
		bottomLeft := this[x floor() as Int, y ceil() as Int]
		topRight := this[x ceil() as Int, y floor() as Int]
		bottomRight := this[x ceil() as Int, y ceil() as Int]

		ColorRgba new(
			(top * (left * topLeft r + (1 - left) * topRight r) + (1 - top) * (left * bottomLeft r + (1 - left) * bottomRight r)),
			(top * (left * topLeft g + (1 - left) * topRight g) + (1 - top) * (left * bottomLeft g + (1 - left) * bottomRight g)),
			(top * (left * topLeft b + (1 - left) * topRight b) + (1 - top) * (left * bottomLeft b + (1 - left) * bottomRight b)),
			(top * (left * topLeft a + (1 - left) * topRight a) + (1 - top) * (left * bottomLeft a + (1 - left) * bottomRight a))
		)
	}

	open: static func (filename: String, coordinateSystem := CoordinateSystem Default) -> This {
		requiredComponents := 4
		(buffer, size, _) := StbImage load(filename, requiredComponents)
		result := This new(buffer, size, coordinateSystem)
		result swapRedBlue()
		result
	}
	savePacked: func (filename: String) -> Int {
		file := File new(filename)
		folder := file parent . mkdirs() . free()
		file free()
		StbImage writePng(filename, this size x, this size y, this bytesPerPixel, this buffer pointer, this size x * this bytesPerPixel)
	}
	save: override func (filename: String) -> Int {
		bgra := this redBlueSwapped()
		result := bgra savePacked(filename)
		bgra free()
		result
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			row := result buffer pointer as PtrDiff
			rowLength := result stride
			rowEnd := row + rowLength
			destination := row as ColorRgba*
			f := func (color: ColorRgb) {
				destination@ = ColorRgba new(color, 255)
				destination += 1
				if (destination >= rowEnd) {
					row += result stride as PtrDiff
					destination = row as ColorRgba*
					rowEnd = row + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
}
