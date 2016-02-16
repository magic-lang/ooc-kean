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
import StbImage
import Image
import Color
import Canvas, RasterCanvas

RasterBgraCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterBgra
	init: func (image: RasterBgra) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toBgra())
	}
}

RasterBgra: class extends RasterPacked {
	bytesPerPixel ::= 4
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterBgra (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		convert := ColorConvert fromBgr(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~bgr (action: Func(ColorBgr)) {
		for (row in 0 .. this size y) {
			source := this buffer pointer + row * this stride
			for (pixel in 0 .. this size x) {
				pixelPointer := (source + pixel * this bytesPerPixel)
				color := (pixelPointer as ColorBgr*)@
				action(color)
			}
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
						if (c alpha < minimum alpha)
							distance += (minimum alpha - c alpha) as Float squared
						else if (c alpha > maximum alpha)
							distance += (c alpha - maximum alpha) as Float squared
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
	_createCanvas: override func -> Canvas { RasterBgraCanvas new(this) }

	operator [] (x, y: Int) -> ColorBgra { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorBgra* + x)@ : ColorBgra new(0, 0, 0, 0) }
	operator []= (x, y: Int, value: ColorBgra) { ((this buffer pointer + y * this stride) as ColorBgra* + x)@ = value }
	operator [] (point: IntPoint2D) -> ColorBgra { this[point x, point y] }
	operator []= (point: IntPoint2D, value: ColorBgra) { this[point x, point y] = value }
	operator [] (point: FloatPoint2D) -> ColorBgra { this [point x, point y] }
	operator [] (x, y: Float) -> ColorBgra {
		left := x - x floor()
		top := y - y floor()

		topLeft := this[x floor() as Int, y floor() as Int]
		bottomLeft := this[x floor() as Int, y ceil() as Int]
		topRight := this[x ceil() as Int, y floor() as Int]
		bottomRight := this[x ceil() as Int, y ceil() as Int]

		ColorBgra new(
			(top * (left * topLeft blue + (1 - left) * topRight blue) + (1 - top) * (left * bottomLeft blue + (1 - left) * bottomRight blue)),
			(top * (left * topLeft green + (1 - left) * topRight green) + (1 - top) * (left * bottomLeft green + (1 - left) * bottomRight green)),
			(top * (left * topLeft red + (1 - left) * topRight red) + (1 - top) * (left * bottomLeft red + (1 - left) * bottomRight red)),
			(top * (left * topLeft alpha + (1 - left) * topRight alpha) + (1 - top) * (left * bottomLeft alpha + (1 - left) * bottomRight alpha))
		)
	}

	open: static func (filename: String) -> This {
		x, y, imageComponents: Int
		requiredComponents := 4
		data := StbImage load(filename, x&, y&, imageComponents&, requiredComponents)
		buffer := ByteBuffer new(data as Byte*, x * y * requiredComponents, true)
		This new(buffer, IntVector2D new(x, y))
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
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
			(f as Closure) free()
		}
		result
	}
	kean_draw_rasterBgra_new: static unmangled func (width, height, stride: Int, data: Void*) -> This {
		result := This new(IntVector2D new(width, height), stride)
		memcpy(result buffer pointer, data, height * stride)
		result
	}
}
