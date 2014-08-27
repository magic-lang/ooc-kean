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
	init: func ~fromSize (size: IntSize2D) { this new(size, CoordinateSystem Default, IntShell2D new()) }
	init: func ~fromStuff (size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		bufSize := RasterPacked calculateLength(size, 1) + 2 * RasterPacked calculateLength(size / 2, 1)
		"RasterYuv420Planar init ~fromStuff" println()
		super(ByteBuffer new(bufSize), size, coordinateSystem, crop)
	}
//	 FIXME but only if we really need it
//	init: func ~fromByteArray (data: UInt8*, size: IntSize2D) { this init(ByteBuffer new(data), size) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { super(buffer, size, CoordinateSystem Default, IntShell2D new()) }
	init: func ~fromEverything (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(buffer, size, coordinateSystem, crop)
	}
	init: func ~fromRasterYuv420Planar (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) {
		this init(original size, original coordinateSystem, original crop)
//		"RasterYuv420Planar init ~fromRasterImage, original: (#{original size}), this: (#{this size}), y stride #{this y stride}" println()
		y := 0
		x := 0
		width := this size width
		yRow := this y pointer as UInt8*
		yDestination := yRow
		uRow := this u pointer as UInt8*
		uDestination := uRow
		vRow := this v pointer as UInt8*
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

				yRow += this y stride
				yDestination = yRow
				if (y % 2 == 0) {
					uRow += this u stride
					uDestination = uRow
					vRow += this v stride
					vDestination = vRow
				}
			}
		}
		original apply(f)
	}
	shift: func (offset: IntSize2D) -> Image {
		result : This
		y = this y shift(offset) as RasterMonochrome
		u = this u shift(offset/2) as RasterMonochrome
		v = this v shift(offset/2) as RasterMonochrome
		result = This new(this size)
		result buffer copyFrom(y buffer, 0, 0, y length)
		result buffer copyFrom(u buffer, 0, y length, u length)
		result buffer copyFrom(v buffer, 0, y length + u length, v length)
		result
	}
	create: func (size: IntSize2D) -> Image {
		result := This new(size)
		result crop = this crop
		result wrap = this wrap
		result
	}
	createY: func -> RasterMonochrome {
		RasterMonochrome new(this pointer, this size)
	}
	createU: func -> RasterMonochrome {
		RasterMonochrome new((this pointer + RasterPacked calculateLength(this size, 1)) as Int*, this size / 2)
	}
	createV: func -> RasterMonochrome {
		RasterMonochrome new((this pointer + RasterPacked calculateLength(this size, 1) + RasterPacked calculateLength(this size / 2, 1)) as Int*, this size / 2)
	}
	copy: func -> Image {
		This new(this)
	}
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: func ~yuv (action: Func (ColorYuv)) {
		yRow := this y pointer as UInt8*
		ySource := yRow
		uRow := this u pointer as UInt8*
		uSource := uRow
		vRow := this v pointer as UInt8*
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

//	FIXME
//	openResource(assembly: ???, name: String) {
//		Image openResource
//	}
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
