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

RasterRgba: class extends RasterPacked {
	bytesPerPixel ::= 4
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this isValidIn(position x, position y))
			this[position x, position y] = ColorRgba mix(this[position x, position y], pen color, pen alphaAsFloat)
	}
	fill: override func (color: ColorRgba) {
		sizeX := this size x
		sizeY := this size y
		thisBuffer := this buffer pointer as ColorRgba*
		thisStride := this stride / this bytesPerPixel
		for (y in 0 .. sizeY)
			for (x in 0 .. sizeX)
				thisBuffer[x + y * thisStride] = color
	}
	copy: override func -> This { This new(this buffer copy(), this size, this stride) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		sizeX := this size x
		sizeY := this size y
		thisBuffer := this buffer pointer
		thisStride := this stride
		for (row in 0 .. sizeY) {
			source := thisBuffer + row * thisStride
			for (pixel in 0 .. sizeX) {
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
			sizeX := this size x
			sizeY := this size y
			thisBuffer := this buffer _pointer as ColorRgba*
			otherBuffer := (other as This) buffer _pointer as ColorRgba*
			thisStride := this stride / this bytesPerPixel
			otherStride := (other as This) stride / this bytesPerPixel
			for (y in 0 .. sizeY)
				for (x in 0 .. sizeX) {
					c := thisBuffer[x + y * thisStride]
					o := otherBuffer[x + y * otherStride]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in 0 maximum(y - this distanceRadius) .. (y + 1 + this distanceRadius) minimum(sizeY))
							for (otherX in 0 maximum(x - this distanceRadius) .. (x + 1 + this distanceRadius) minimum(sizeX))
								if (otherX != x || otherY != y) {
									pixel := otherBuffer[otherX + otherY * otherStride]
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
			result /= this size norm
		}
		result
	}
	swapRedBlue: func { this swapChannels(0, 2) }
	redBlueSwapped: func -> This {
		result := this copy()
		result swapRedBlue()
		result
	}
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

	open: static func (filename: String) -> This {
		requiredComponents := 4
		(buffer, size, _) := StbImage load(filename, requiredComponents)
		This new(buffer, size)
	}
	savePacked: func (filename: String) -> Int {
		File createParentDirectories(filename)
		StbImage writePng(filename, this size x, this size y, this bytesPerPixel, this buffer pointer, this size x * this bytesPerPixel)
	}
	save: override func (filename: String) -> Int { this savePacked(filename) }
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original size)
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
