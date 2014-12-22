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
	init: func ~fromRasterImages (y: RasterMonochrome, u: RasterMonochrome, v: RasterMonochrome) {
		super(y, u, v)
	}
	init: func ~allocate (size: IntSize2D, align := 0, verticalAlign := 0) {
		(y, u, v) := this _allocate(size, align, verticalAlign)
		super(y, u, v)
	}
	init: func ~fromRasterImage (original: RasterImage) {
		(y, u, v) := this _allocate(original size)
		super(original, y, u, v)
	}
	_allocate: func (size: IntSize2D, align := 0, verticalAlign := 0) -> (RasterMonochrome, RasterMonochrome, RasterMonochrome) {
		yLength := Int align(size width, align) * Int align(size height, verticalAlign)
		uLength := Int align(size width / 2, align) * Int align(size height / 2, verticalAlign)
		buffer := ByteBuffer new(yLength + 2 * uLength)
		(
			RasterMonochrome new(buffer slice(0, yLength), size, align),
			RasterMonochrome new(buffer slice(yLength, uLength), size / 2, align),
			RasterMonochrome new(buffer slice(yLength + uLength, uLength), size / 2, align)
		)
	}
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This {
		result := This new(this)
		this y buffer copyTo(result y buffer)
		this u buffer copyTo(result u buffer)
		this v buffer copyTo(result v buffer)
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
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
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
	}
	convertFrom: static func(original: RasterImage) -> This {
		result := This new(original)
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
