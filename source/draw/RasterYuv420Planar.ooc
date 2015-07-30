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
import RasterYuvPlanar
import RasterMonochrome
import Image
import Color

RasterYuv420Planar: class extends RasterYuvPlanar {
	stride ::= this _y stride
	init: func ~fromRasterImages (y: RasterMonochrome, u: RasterMonochrome, v: RasterMonochrome) { super(y, u, v) }
	init: func ~allocateOffset (size: IntSize2D, stride: UInt, uOffset: UInt, vOffset: UInt) {
		(yImage, uImage, vImage) := This _allocate(size, stride, uOffset, vOffset)
		this init(yImage, uImage, vImage)
	}
	init: func ~allocateStride (size: IntSize2D, stride: UInt) {
		yLength := stride * size height
		uLength := stride * size height / 4
		this init(size, stride, yLength, yLength + uLength)
	}
	init: func ~allocate (size: IntSize2D) { this init(size, size width) }
	init: func ~fromThis (original: This) {
		uOffset := original stride * original size height
		vOffset := uOffset + original stride * original size height / 4
		(yImage, uImage, vImage) := RasterYuv420Planar _allocate(original size, original stride, uOffset, vOffset)
		super(original, yImage, uImage, vImage)
	}
	_allocate: static func (size: IntSize2D, stride: UInt, uOffset: UInt, vOffset: UInt) -> (RasterMonochrome, RasterMonochrome, RasterMonochrome) {
		yLength := stride * size height
		uLength := stride * size height / 4
		vLength := uLength
		length := vOffset + vLength
		buffer := ByteBuffer new(length)
		(
			RasterMonochrome new(buffer slice(0, yLength), size, stride),
			RasterMonochrome new(buffer slice(uOffset, uLength), IntSize2D new(size width / 2, size height / 4), stride / 2),
			RasterMonochrome new(buffer slice(vOffset, vLength), IntSize2D new(size width / 2, size height / 4), stride / 2)
		)
	}
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this y buffer copyTo(result y buffer)
		this u buffer copyTo(result u buffer)
		this v buffer copyTo(result v buffer)
		result
	}
	apply: func ~bgr (action: Func(ColorBgr)) { this apply(ColorConvert fromYuv(action)) }
	apply: func ~yuv (action: Func (ColorYuv)) {
		yRow := this y buffer pointer
		ySource := yRow
		uRow := this u buffer pointer
		uSource := uRow
		vRow := this v buffer pointer
		vSource := vRow
		width := this size width
		height := this size height

		for (y in 0..height) {
			for (x in 0..width) {
				action(ColorYuv new(ySource@, uSource@, vSource@))
				ySource += 1
				if (x % 2 == 1) {
					uSource += 1
					vSource += 1
				}
			}
			yRow += this y stride
			if (y % 2 == 1) {
				uRow += this u stride
				vRow += this v stride
			}
			ySource = yRow
			uSource = uRow
			vSource = vRow
		}
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) { this apply(ColorConvert fromYuv(action)) }
	convertFrom: static func(original: RasterImage) -> This {
		result := This new(original size)
		y := 0
		x := 0
		width := result size width
		yRow := result y buffer pointer
		yDestination := yRow
		uRow := result u buffer pointer
		uDestination := uRow
		vRow := result v buffer pointer
		vDestination := vRow
		//		C#: original.Apply(color => *((Color.Bgra*)destination++) = new Color.Bgra(color, 255));
		f := func (color: ColorYuv) {
			(yDestination)@ = color y
			yDestination += 1
			if (x % 2 == 0 && y % 2 == 0) {
				uDestination@ = color u
				uDestination += 1
				vDestination@ = color v
				vDestination += 1
			}
			x += 1
			if (x >= width) {
				x = 0
				y += 1

				yRow += result y stride
				yDestination = yRow
				if (y % 2 == 0) {
					uRow += result u stride
					uDestination = uRow
					vRow += result v stride
					vDestination = vRow
				}
			}
		}
		original apply(f)
		result
	}
	operator [] (x, y: Int) -> ColorYuv {
		ColorYuv new(0, 0, 0)
		ColorYuv new(this y[x, y] y, this u [x/2, y/2] y, this v [x/2, y/2] y)
	}
	operator []= (x, y: Int, value: ColorYuv) {
		this y[x, y] = ColorMonochrome new(value y)
		this u[x/2, y/2] = ColorMonochrome new(value u)
		this v[x/2, y/2] = ColorMonochrome new(value v)
	}
}
