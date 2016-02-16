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
import Canvas, RasterCanvas, RasterBgr

RasterRgbCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterRgb
	init: func (image: RasterRgb) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toRgb())
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		rgb: RasterRgb = null
		if (image instanceOf(RasterRgb))
			rgb = image as RasterRgb
		else if (image instanceOf(RasterImage))
			rgb = RasterRgb convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RgbRasterCanvas draw")
		this _resizePacked(rgb buffer pointer as ColorRgb*, rgb, source, destination)
		if (rgb != image)
			rgb referenceCount decrease()
	}
}

RasterRgb: class extends RasterPacked {
	bytesPerPixel ::= 3
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterRgb (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		for (row in 0 .. this size y)
			for (pixel in 0 .. this size x) {
				pointer := this buffer pointer + pixel * this bytesPerPixel + row * this stride
				color := (pointer as ColorRgb*)@
				action(color)
			}
	}
	apply: override func ~bgr (action: Func(ColorBgr)) {
		convert := ColorConvert fromRgb(action)
		this apply(convert)
		(convert as Closure) free()
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
	resizeTo: override func (size: IntVector2D) -> This {
		result := This new(size)
		result canvas draw(this, IntBox2D new(this size), IntBox2D new(size))
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
	_createCanvas: override func -> Canvas { RasterRgbCanvas new(this) }

	operator [] (x, y: Int) -> ColorRgb { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorRgb* + x)@ : ColorRgb new(0, 0, 0) }
	operator []= (x, y: Int, value: ColorRgb) { ((this buffer pointer + y * this stride) as ColorRgb* + x)@ = value }

	open: static func (filename: String) -> This {
		This convertFrom(RasterBgr open(filename))
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			row := result buffer pointer as Long
			rowLength := result size x
			rowEnd := row as ColorRgb* + rowLength
			destination := row as ColorRgb*
			f := func (color: ColorRgb) {
				(destination as ColorRgb*)@ = color
				destination += 1
				if (destination >= rowEnd) {
					row += result stride
					destination = row as ColorRgb*
					rowEnd = row as ColorRgb* + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	kean_draw_rasterRgb_new: static unmangled func (width, height, stride: Int, data: Void*) -> This {
		result := This new(IntVector2D new(width, height), stride)
		memcpy(result buffer pointer, data, height * stride)
		result
	}
}
