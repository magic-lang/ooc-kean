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
import RasterPacked
import RasterImage
import RasterMonochrome
import Image
import Color
import RasterBgr
import StbImage
import io/File
import io/FileReader
import io/Reader
import io/FileWriter

RasterYuv422Semipacked: class extends RasterPacked {
	bytesPerPixel ::= 2
	init: func ~allocate (size: IntSize2D) { super~allocate(size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, this bytesPerPixel * size width) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: func (size: IntSize2D) -> Image {
		result := This new(size)
		result crop = this crop
		result wrap = this wrap
		result
	}
	copy: func -> This {
		result := This new(this size)
		this buffer copyTo(result buffer)
		result
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) dispose()
	}
	apply: func ~yuv (action: Func (ColorYuv)) {
		row := this buffer pointer as UInt8*
		source := row
		width := this size width
		height := this size height

		for (y in 0 .. height) {
			for (x in 0 .. width) {
				action(ColorYuv new((source + 1)@, (source - 2*(x % 2))@, (source + 2*((x + 1) % 2))@))
				source += 2
			}
			row += this stride
		}
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) dispose()
	}
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
			(index - 2*((x + 1) % 2))@ = ColorMonochrome new(value v)
		}
	}
	open: static func (filename: String) -> This {
		bgr := RasterBgr open(filename)
		result := This convertFrom(bgr)
		bgr referenceCount decrease()
		result
	}
	save: func (filename: String) {
		bgr := RasterBgr convertFrom(this)
		bgr save(filename)
		bgr referenceCount decrease()
	}
	saveRaw: func (filename: String) {
		fileWriter := FileWriter new(filename)
		fileWriter write(this buffer pointer as Char*, this buffer size)
		fileWriter close()
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf?(This))
			result = (original as This) copy()
		else {
			result = This new(original size)
			y := 0
			x := 0
			width := result size width
			row := result buffer pointer as UInt8*
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
			(f as Closure) dispose()
		}
		result
	}
	openRaw: static func (filename: String, size: IntSize2D) -> This {
		fileReader := FileReader new(FStream open(filename, "rb"))
		result := This new(size)
		fileReader read((result buffer pointer as Char*), 0, result buffer size)
		fileReader close()
		fileReader free()
		result
	}
}
