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
import RasterMonochrome
import Image
import Color
import Pen
import RasterRgb
import StbImage
import io/File
import io/FileReader
import io/Reader
import io/FileWriter
import Canvas, RasterCanvas

RasterYuv422SemipackedCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterYuv422Semipacked
	init: func (image: RasterYuv422Semipacked) { super(image) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(pen alphaAsFloat, pen color toYuv())
	}
}

RasterYuv422Semipacked: class extends RasterPacked {
	bytesPerPixel ::= 2
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { super(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image {
		result := This new(size)
		result crop = this crop
		result wrap = this wrap
		result
	}
	copy: override func -> This {
		result := This new(this size)
		this buffer copyTo(result buffer)
		result
	}
	apply: override func ~rgb (action: Func(ColorRgb)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) free()
	}
	apply: override func ~yuv (action: Func (ColorYuv)) {
		row := this buffer pointer as Byte*
		source := row
		width := this size x
		height := this size y

		for (y in 0 .. height) {
			for (x in 0 .. width) {
				action(ColorYuv new((source + 1)@, (source - 2*(x % 2))@, (source + 2*((x + 1) % 2))@))
				source += 2
			}
			row += this stride
		}
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) free()
	}
	save: func (filename: String) {
		rgb := RasterRgb convertFrom(this)
		rgb save(filename)
		rgb referenceCount decrease()
	}
	saveRaw: func (filename: String) {
		fileWriter := FileWriter new(filename)
		fileWriter write(this buffer pointer as Char*, this buffer size)
		fileWriter close()
	}
	_createCanvas: override func -> Canvas { RasterYuv422SemipackedCanvas new(this) }

	operator [] (x, y: Int) -> ColorYuv {
		result := ColorYuv new()
		if (this isValidIn(x, y)) {
			index := (this buffer pointer + y * this stride + x * this bytesPerPixel) as ColorMonochrome* // U or V value
			result = ColorYuv new((index + 1)@ y, (index - 2*(x % 2))@ y, (index + 2*((x + 1) % 2))@ y)
		}
		result
	}
	operator []= (x, y: Int, value: ColorYuv) {
		if (this isValidIn(x, y)) {
			index := (this buffer pointer + y * this stride + x * this bytesPerPixel) as ColorMonochrome* // U or V value
			(index + 1)@ = ColorMonochrome new(value y)
			(index - 2*(x % 2))@ = ColorMonochrome new(value u)
			(index + 2*((x + 1) % 2))@ = ColorMonochrome new(value v)
		}
	}

	open: static func (filename: String, coordinateSystem := CoordinateSystem Default) -> This {
		rgb := RasterRgb open(filename, coordinateSystem)
		result := This convertFrom(rgb)
		rgb referenceCount decrease()
		result
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			y := 0
			x := 0
			width := result size x
			row := result buffer pointer as Byte*
			destination := row
			f := func (color: ColorYuv) {
				destination@ = (x % 2) ? color v : color u
				destination += 1
				destination@ = color y
				destination += 1
				x += 1
				if (x >= width) {
					x = 0
					y += 1
					row += result stride
					destination = row
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
	openRaw: static func (filename: String, size: IntVector2D) -> This {
		fileReader := FileReader new(FStream open(filename, "rb"))
		result := This new(size)
		fileReader read((result buffer pointer as Char*), 0, result buffer size)
		fileReader close()
		fileReader free()
		result
	}
	writePixelGpu: override func (x, y: Int, color: ColorRgba) {
		raise("writePixelGpu unimplemented for RasterYuv422Semipacked")
	}
	readPixelGpu: override func (x, y: Int) -> ColorRgba {
		raise("writePixelGpu unimplemented for RasterYuv422Semipacked")
		ColorRgba new(0, 0, 0, 255)
	}
}
