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
import RasterYuvSemiplanar
import RasterMonochrome
import RasterUv
import Image
import Color
import RasterBgr
import StbImage
import io/File
import io/FileReader
import io/Reader
import io/FileWriter
import io/BinarySequence

RasterYuv420Semiplanar: class extends RasterYuvSemiplanar {
	stride ::= this _y stride
	init: func ~fromRasterImages (yImage: RasterMonochrome, uvImage: RasterUv) { super(yImage, uvImage) }
	init: func ~allocateOffset (size: IntSize2D, stride: UInt, uvOffset: UInt) {
		(yImage, uvImage) := This _allocate(size, stride, uvOffset)
		this init(yImage, uvImage)
	}
	init: func ~allocateStride (size: IntSize2D, stride: UInt) { this init(size, stride, stride * size height) }
	init: func ~allocate (size: IntSize2D) { this init(size, size width) }
	init: func ~fromThis (original: This) {
		(yImage, uvImage) := This _allocate(original size, original stride, original stride * original size height)
		super(original, yImage, uvImage)
	}
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D, stride: UInt, uvOffset: UInt) {
		(yImage, uvImage) := This _createSubimages(buffer, size, stride, uvOffset)
		this init(yImage, uvImage)
	}
	_allocate: static func (size: IntSize2D, stride: UInt, uvOffset: UInt) -> (RasterMonochrome, RasterUv) {
		length := uvOffset + stride * size height / 2
		buffer := ByteBuffer new(length)
		This _createSubimages(buffer, size, stride, uvOffset)
	}
	_createSubimages: static func (buffer: ByteBuffer, size: IntSize2D, stride: UInt, uvOffset: UInt) -> (RasterMonochrome, RasterUv) {
		yLength := stride * size height
		uvLength := stride * size height / 2
		(RasterMonochrome new(buffer slice(0, yLength), size, stride), RasterUv new(buffer slice(uvOffset, uvLength), size / 2, stride))
	}

	/*shift: func (offset: IntSize2D) -> Image {
		result : This
		y = this y shift(offset) as RasterMonochrome
		uv = this uv shift(offset / 2) as RasterMonochrome
		result = This new(this size)
		result buffer copyFrom(y buffer, 0, 0, y length)
		result buffer copyFrom(uv buffer, 0, y length, uv length)
		result
	}*/
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this y buffer copyTo(result y buffer)
		this uv buffer copyTo(result uv buffer)
		result
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: func ~yuv (action: Func (ColorYuv)) {
		yRow := this y buffer pointer
		ySource := yRow
		uvRow := this uv buffer pointer
		vSource := uvRow
		uSource := uvRow + 1
		width := this size width
		height := this size height

		for (y in 0..height) {
			for (x in 0..width) {
				action(ColorYuv new(ySource@, uSource@, vSource@))
				ySource += 1
				if (x % 2 == 1) {
					uSource += 2
					vSource += 2
				}
			}
			yRow += this y stride
			if (y % 2 == 1) {
				uvRow += this uv stride
			}
			ySource = yRow
			vSource = uvRow
			uSource = uvRow + 1
		}
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
	}

//	FIXME
//	openResource(assembly: ???, name: String) {
//		Image openResource
//	}
	operator [] (x, y: Int) -> ColorYuv {
		ColorYuv new(0, 0, 0)
		ColorYuv new(this y[x, y] y, this uv [x / 2, y / 2] u, this uv [x / 2, y / 2] v)
	}
	operator []= (x, y: Int, value: ColorYuv) {
		this y[x, y] = ColorMonochrome new(value y)
		this uv[x / 2, y / 2] = ColorUv new(value u, value v)
	}
	convertFrom: static func(original: RasterImage) -> This {
		result := This new(original size)
		//		"RasterYuv420 init ~fromRasterImage, original: (#{original size}), this: (#{this size}), y stride #{this y stride}" println()
		y := 0
		x := 0
		width := result size width
		yRow := result y buffer pointer
		yDestination := yRow
		uvRow := result uv buffer pointer
		vDestination := uvRow
		uDestination := uvRow + 1
		//		C#: original.Apply(color => *((Color.Bgra*)destination++) = new Color.Bgra(color, 255));
		f := func (color: ColorYuv) {
			(yDestination)@ = color y
			yDestination += 1
			if (x % 2 == 0 && y % 2 == 0) {
				uDestination@ = color u
				uDestination += 2
				vDestination@ = color v
				vDestination += 2
			}
			x += 1
			if (x >= width) {
				x = 0
				y += 1
				yRow += result y stride
				yDestination = yRow
				if (y % 2 == 0) {
					uvRow += result uv stride
					vDestination = uvRow
					uDestination = uvRow + 1
				}
			}
		}
		original apply(f)
		result
	}
	open: static func (filename: String) -> This {
		bgr := RasterBgr open(filename)
		result := This convertFrom(bgr)
		bgr free()
		result
	}
	save: override func (filename: String) -> Int {
		bgr := RasterBgr convertFrom(this)
		result := bgr save(filename)
		bgr free()
		result
	}
	openRaw: static func (filename: String, size: IntSize2D) -> This {
		fileReader := FileReader new(FStream open(filename, "rb"))
		result := This new(size)
		fileReader read((result y buffer pointer as Char*), 0, result y buffer size)
		fileReader read((result uv buffer pointer as Char*), 0, result uv buffer size)
		fileReader close()
		fileReader free()
		result
	}
	saveRaw: func (filename: String) {
		fileWriter := FileWriter new(filename)
		fileWriter write(this y buffer pointer as Char*, this y buffer size)
		fileWriter write(this uv buffer pointer as Char*, this uv buffer size)
		fileWriter close()
	}
}
