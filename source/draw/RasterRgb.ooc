/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use draw
import RasterPacked
import RasterImage
import RasterRgba
import io/File
import StbImage
import Image
import Color
import Pen

RasterRgb: class extends RasterPacked {
	bytesPerPixel ::= 3
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this isValidIn(position x, position y))
			this[position x, position y] = ColorRgb mix(this[position x, position y], pen color toRgb(), pen alphaAsFloat)
	}
	_draw: override func (image: Image, source, destination: IntBox2D, normalizedTransform: FloatTransform3D, interpolate, flipX, flipY: Bool) {
		rgb: This = null
		if (image == null)
			Debug error("Null image in RasterRgb draw")
		else if (image instanceOf(This))
			rgb = image as This
		else if (image instanceOf(RasterImage))
			rgb = This convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RasterRgb draw")
		this _resizePacked(rgb buffer pointer as ColorRgb*, rgb, source, destination, normalizedTransform, interpolate, flipX, flipY, ColorRgb new())
		if (rgb != image)
			rgb referenceCount decrease()
	}
	fill: override func (color: ColorRgba) {
		sizeX := this size x
		sizeY := this size y
		thisBuffer := this buffer pointer as ColorRgb*
		thisStride := this stride / this bytesPerPixel
		colorRgb := color toRgb()
		for (y in 0 .. sizeY)
			for (x in 0 .. sizeX)
				thisBuffer[x + y * thisStride] = colorRgb
	}
	copy: override func -> This { This new(this buffer copy(), this size, this stride) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		sizeX := this size x
		sizeY := this size y
		thisBuffer := this buffer pointer
		thisStride := this stride
		for (row in 0 .. sizeY)
			for (pixel in 0 .. sizeX) {
				pointer := thisBuffer + pixel * this bytesPerPixel + row * thisStride
				color := (pointer as ColorRgb*)@
				action(color)
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
	resizeTo: override func (size: IntVector2D) -> This { this resizeTo(size, true) as This }
	resizeTo: override func ~withMethod (size: IntVector2D, interpolate: Bool) -> This {
		result := This new(size)
		DrawState new(result) setInputImage(this) setInterpolate(interpolate) draw()
		result
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
			thisBuffer := this buffer _pointer as ColorRgb*
			otherBuffer := (other as This) buffer _pointer as ColorRgb*
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
						result += (distance) sqrt() / 3
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
	operator [] (x, y: Int) -> ColorRgb { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorRgb* + x)@ : ColorRgb new(0, 0, 0) }
	operator []= (x, y: Int, value: ColorRgb) { ((this buffer pointer + y * this stride) as ColorRgb* + x)@ = value }
	open: static func (filename: String) -> This {
		rgba := RasterRgba open(filename)
		result := This convertFrom(rgba)
		rgba referenceCount decrease()
		result
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
			rowLength := result size x
			rowEnd := row as ColorRgb* + rowLength
			destination := row as ColorRgb*
			f := func (color: ColorRgb) {
				destination@ = color
				destination += 1
				if (destination >= rowEnd) {
					row += result stride as PtrDiff
					destination = row as ColorRgb*
					rowEnd = row as ColorRgb* + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
}
