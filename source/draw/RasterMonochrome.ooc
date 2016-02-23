/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use math
use geometry
import RasterPacked
import RasterImage
import StbImage
import Image, FloatImage
import Color
import Canvas, RasterCanvas

RasterMonochromeCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterMonochrome
	init: func (image: RasterMonochrome) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toMonochrome())
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		monochrome: RasterMonochrome = null
		if (image instanceOf(RasterMonochrome))
			monochrome = image as RasterMonochrome
		else if (image instanceOf(RasterImage))
			monochrome = RasterMonochrome convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RasterMonochromeCanvas draw")
		this _resizePacked(monochrome buffer pointer as ColorMonochrome*, monochrome, source, destination)
		if (monochrome != image)
			monochrome referenceCount decrease()
	}
}

RasterMonochrome: class extends RasterPacked {
	bytesPerPixel ::= 1
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterMonochrome (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		convert := ColorConvert fromMonochrome(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~yuv (action: Func(ColorYuv)) {
		convert := ColorConvert fromMonochrome(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		pointer := this buffer pointer as ColorMonochrome*
		for (row in 0 .. this size y)
			for (column in 0 .. this size x) {
				pixel := pointer + row * this stride + column
				action(pixel@)
			}
	}
	resizeTo: override func (size: IntVector2D) -> This {
		this resizeTo(size, InterpolationMode Smooth) as This
	}
	resizeTo: override func ~withMethod (size: IntVector2D, method: InterpolationMode) -> This {
		result := This new(size)
		result canvas interpolationMode = method
		result canvas draw(this, IntBox2D new(this size), IntBox2D new(size))
		//TODO will be fixed by subcanvas
		result canvas interpolationMode = InterpolationMode Fast
		result
	}
	distance: override func (other: Image) -> Float {
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
						for (otherY in 0 maximum(y - 2) .. (y + 3) minimum(this size y))
							for (otherX in 0 maximum(x - 2) .. (x + 3) minimum(this size x))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
									if (maximum y < pixel y)
										maximum y = pixel y
									else if (minimum y > pixel y)
										minimum y = pixel y
								}
						distance := 0.0f
						if (c y < minimum y)
							distance += (minimum y - c y) as Float squared
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared
						result += distance sqrt()
					}
				}
			result /= (this size x squared + this size y squared as Float sqrt())
		}
		result
	}
	getFirstDerivative: func (x, y: Int) -> (Float, Float) {
		step := 2
		sourceStride := this stride
		source := this buffer pointer + y * sourceStride
		derivativeX := (8 * source[x + step] - 8 * source[x - step] + source[x - 2 * step] - source[x + 2 * step]) as Float / (12.0f * step)
		derivativeY := (8 * source[x + sourceStride * step] - 8 * source[x - sourceStride * step] + source[x - sourceStride * 2 * step] - source[x + sourceStride * 2 * step]) as Float / (12.0f * step)
		(derivativeX, derivativeY)
	}
	// get the derivative on small window, region is window's global location on image, window is left top centered.
	getFirstDerivative: func ~window (region: IntBox2D, imageX, imageY: FloatImage) {
		step := 2
		sourceStride := this stride
		source := this buffer pointer + region leftTop y * sourceStride // this getValue [x,y]
		destinationX := imageX pointer
		destinationY := imageY pointer

		// Ix & Iy  centered difference approximation with 4th error order, centered window
		for (y in (region leftTop y) .. (region rightBottom y)) {
			for (x in (region leftTop x) .. (region rightBottom x)) {
				destinationX@ = (
					8 * source[x + step] -
					8 * source[x - step] +
					source[x - 2 * step] -
					source[x + 2 * step]
				) as Float / (12.0f * step)
				destinationX += 1

				destinationY@ = (
					8 * source[x + sourceStride * step] -
					8 * source[x - sourceStride * step] +
					source[x - sourceStride * 2 * step] -
					source[x + sourceStride * 2 * step]
				) as Float / (12.0f * step)
				destinationY += 1
			}
			source += sourceStride
		}
	}

	getValue: func (x, y: Int) -> Byte {
		version(safe)
			raise(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in getValue")
		(this buffer pointer[y * this stride + x])
	}

	getRow: func (row: Int) -> FloatVectorList {
		result := FloatVectorList new(this size x)
		this getRowInto(row, result)
		result
	}
	getRowInto: func (row: Int, vector: FloatVectorList) {
		version(safe)
			raise(row >= this size y || row < 0, "Accessing RasterMonochrome index out of range in getRow")
		for (column in 0 .. this size x)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	getColumn: func (column: Int) -> FloatVectorList {
		result := FloatVectorList new(this size y)
		this getColumnInto(column, result)
		result
	}
	getColumnInto: func (column: Int, vector: FloatVectorList) {
		version(safe)
			raise(column >= this size x || column < 0, "Accessing RasterMonochrome index out of range in getColumn")
		for (row in 0 .. this size y)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	_createCanvas: override func -> Canvas { RasterMonochromeCanvas new(this) }

	operator [] (x, y: Int) -> ColorMonochrome {
		version(safe)
			raise(!this isValidIn(x, y), "Accessing RasterMonochrome index out of range in get operator")
		ColorMonochrome new(this buffer pointer[y * this stride + x])
	}
	operator []= (x, y: Int, value: ColorMonochrome) {
		version(safe)
			raise(x >= this size x || y >= this size y || x < 0 || y < 0, "Accessing RasterMonochrome index out of range in set operator")
		((this buffer pointer + y * this stride) as ColorMonochrome* + x)@ = value
	}

	open: static func (filename: String) -> This {
		x, y, imageComponents: Int
		requiredComponents := 1
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
			destination := row
			f := func (color: ColorMonochrome) {
				(destination as ColorMonochrome*)@ = color
				destination += 1
				if (destination >= rowEnd) {
					row += result stride
					destination = row
					rowEnd = row + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	kean_draw_rasterMonochrome_new: static unmangled func (width, height, stride: Int, data: Void*) -> This {
		result := This new(IntVector2D new(width, height), stride)
		memcpy(result buffer pointer, data, height * stride)
		result
	}
}
