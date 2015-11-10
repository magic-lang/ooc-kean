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
import Canvas, RasterCanvas

Yuv420RasterCanvas: class extends RasterCanvas {
	target ::= this _target as RasterYuv420Semiplanar
	init: func (image: RasterYuv420Semiplanar) { super(image) }
	_drawPoint: override func (x, y: Int) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(this pen alphaAsFloat, this pen color toYuv())
	}
}

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
		length := uvOffset + stride * (size height + 1) / 2
		buffer := ByteBuffer new(length)
		This _createSubimages(buffer, size, stride, uvOffset)
	}
	_createSubimages: static func (buffer: ByteBuffer, size: IntSize2D, stride: UInt, uvOffset: UInt) -> (RasterMonochrome, RasterUv) {
		yLength := stride * size height
		uvLength := stride * size height / 2
		(RasterMonochrome new(buffer slice(0, yLength), size, stride), RasterUv new(buffer slice(uvOffset, uvLength), This _uvSize(size), stride))
	}
	_uvSize: static func (size: IntSize2D) -> IntSize2D {
		IntSize2D new(size width / 2 + (Int odd(size width) ? 1 : 0), size height / 2 + (Int odd(size height) ? 1 : 0))
	}
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this y buffer copyTo(result y buffer)
		this uv buffer copyTo(result uv buffer)
		result
	}
	resizeTo: override func (size: IntSize2D) -> This {
		result: This
		if (this size == size)
			result = this copy()
		else {
			result = This new(size, size width + (Int odd(size width) ? 1 : 0))
			this resizeInto(result)
		}
		result
	}
	resizeInto: func (target: This) {
		thisYBuffer := this y buffer pointer
		targetYBuffer := target y buffer pointer
		for (row in 0 .. target size height) {
			srcRow := (this size height * row) / target size height
			thisStride := srcRow * this y stride
			targetStride := row * target y stride
			for (column in 0 .. target size width) {
				srcColumn := (this size width * column) / target size width
				targetYBuffer[column + targetStride] = thisYBuffer[srcColumn + thisStride]
			}
		}
		targetSizeHalf := target size / 2
		thisSizeHalf := this size / 2
		thisUvBuffer := this uv buffer pointer as ColorUv*
		targetUvBuffer := target uv buffer pointer as ColorUv*
		if (Int odd(target size height))
			targetSizeHalf = IntSize2D new(targetSizeHalf width, targetSizeHalf height + 1)
		for (row in 0 .. targetSizeHalf height) {
			srcRow := (thisSizeHalf height * row) / targetSizeHalf height
			thisStride := srcRow * this uv stride / 2
			targetStride := row * target uv stride / 2
			for (column in 0 .. targetSizeHalf width) {
				srcColumn := (thisSizeHalf width * column) / targetSizeHalf width
				targetUvBuffer[column + targetStride] = thisUvBuffer[srcColumn + thisStride]
			}
		}
	}
	crop: func (region: FloatBox2D) -> This {
		size := region size toIntSize2D()
		result := This new(size, size width + (Int odd(size width) ? 1 : 0)) as This
		this cropInto(region, result)
		result
	}
	cropInto: func (region: FloatBox2D, target: This) {
		thisYBuffer := this y buffer pointer
		targetYBuffer := target y buffer pointer
		for (row in region top .. region size height + region top) {
			thisStride := row * this y stride
			targetStride := ((row - region top) as Int) * target y stride
			for (column in region left .. region size width + region left)
				targetYBuffer[(column - region left) as Int + targetStride] = thisYBuffer[column + thisStride]
		}
		regionSizeHalf := region size / 2
		regionTopHalf := region top / 2
		regionLeftHalf := region left / 2
		thisUvBuffer := this uv buffer pointer as ColorUv*
		targetUvBuffer := target uv buffer pointer as ColorUv*
		for (row in regionTopHalf .. regionSizeHalf height + regionTopHalf) {
			thisStride := row * this uv stride / 2
			targetStride := ((row - regionTopHalf) as Int) * target uv stride / 2
			for (column in regionLeftHalf .. regionSizeHalf width + regionLeftHalf)
				targetUvBuffer[(column - regionLeftHalf) as Int + targetStride] = thisUvBuffer[column + thisStride]
		}
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) dispose()
	}
	apply: func ~yuv (action: Func (ColorYuv)) {
		yRow := this y buffer pointer
		ySource := yRow
		uvRow := this uv buffer pointer
		vSource := uvRow
		uSource := uvRow + 1
		width := this size width
		height := this size height

		for (y in 0 .. height) {
			for (x in 0 .. width) {
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
		convert := ColorConvert fromYuv(action)
		this apply(convert)
		(convert as Closure) dispose()
	}
	operator [] (x, y: Int) -> ColorYuv {
		ColorYuv new(this y[x, y] y, this uv [x / 2, y / 2] u, this uv [x / 2, y / 2] v)
	}
	operator []= (x, y: Int, value: ColorYuv) {
		this y[x, y] = ColorMonochrome new(value y)
		this uv[x / 2, y / 2] = ColorUv new(value u, value v)
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
			yRow := result y buffer pointer
			yDestination := yRow
			uvRow := result uv buffer pointer
			uvDestination := uvRow
			totalOffset := 0
			//		C#: original.Apply(color => *((Color.Bgra*)destination++) = new Color.Bgra(color, 255));
			f := func (color: ColorYuv) {
				yDestination@ = color y
				yDestination += 1
				if (x % 2 == 0 && y % 2 == 0 && totalOffset < result uv buffer size) {
					uvDestination@ = color v
					uvDestination += 1
					uvDestination@ = color u
					uvDestination += 1
					totalOffset += 2
				}
				x += 1
				if (x >= width) {
					x = 0
					y += 1
					yRow += result y stride
					yDestination = yRow
					if (y % 2 == 0) {
						uvRow += result uv stride
						uvDestination = uvRow
					}
				}
			}
			original apply(f)
			(f as Closure) dispose()
		}
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
	_createCanvas: override func -> Canvas { Yuv420RasterCanvas new(this) }
	kean_draw_rasterYuv420Semiplanar_new: static unmangled func (width, height, stride: Int, monochromeData, uvData: Void*) -> This {
		result := This new(IntSize2D new(width, height), stride)
		memcpy(result uv buffer pointer, uvData, (height / 2) * stride)
		memcpy(result y buffer pointer, monochromeData, height * stride)
		result
	}
	kean_draw_rasterYuv420Semiplanar_getMonochromeData: unmangled func -> Void* { this y buffer pointer }
	kean_draw_rasterYuv420Semiplanar_getUvData: unmangled func -> Void* { this uv buffer pointer }
}
