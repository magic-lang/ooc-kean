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
import StbImage
import Image, FloatImage
import Color
import PaintEngine
import RasterPaintEngine

RasterMonochrome: class extends RasterPacked {
	bytesPerPixel: Int { get { 1 } }
	init: func ~allocate (size: IntSize2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntSize2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntSize2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntSize2D) { this init(buffer, size, this bytesPerPixel * size width) }
	init: func ~fromRasterImage (original: This) { super(original) }
	create: func (size: IntSize2D) -> Image { This new(size) }
	copy: func -> This { This new(this) }
	apply: func ~bgr (action: Func(ColorBgr)) {
		this apply(ColorConvert fromMonochrome(action))
	}
	apply: func ~yuv (action: Func(ColorYuv)) {
		this apply(ColorConvert fromMonochrome(action))
	}
	apply: func ~monochrome (action: Func(ColorMonochrome)) {
		pointer := this buffer pointer as ColorMonochrome*
		for (row in 0 .. this height)
			for (column in 0 .. this width) {
				pixel := pointer + row * this stride + column
				action(pixel@)
			}
	}
	resizeTo: override func (size: IntSize2D) -> This {
		result: This
		if (this size == size)
			result = this copy()
		else {
			result = This new(size)
			for (row in 0 .. size height) {
				srcRow := (this size height * row) / size height
				for (column in 0 .. size width) {
					srcColumn := (this size width * column) / size width
					result[column, row] = this[srcColumn, srcRow]
				}
			}
		}
		result
	}
	distance: override func (other: Image) -> Float {
		result := 0.0f
		if (!other)
			result = Float maximumValue
//		else if (!other instanceOf?(This))
//			FIXME
//		else if (this size != other size)
//			FIXME
		else {
			for (y in 0 .. this size height)
				for (x in 0 .. this size width) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum~two(0, y - 2) .. Int minimum~two(y + 3, this size height))
							for (otherX in Int maximum~two(0, x - 2) .. Int minimum~two(x + 3, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
									if (maximum y < pixel y)
										maximum y = pixel y
									else if (minimum y > pixel y)
										minimum y = pixel y
								}
						distance := 0.0f
						if (c y < minimum y)
							distance += (minimum y - c y) as Float squared()
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared()
						result += distance sqrt()
					}
				}
			result /= ((this size width squared() + this size height squared()) as Float sqrt())
		}
	}
	open: static func (filename: String) -> This {
		x, y, imageComponents: Int
		requiredComponents := 1
		data := StbImage load(filename, x&, y&, imageComponents&, requiredComponents)
		This new(ByteBuffer new(data as UInt8*, x * y * requiredComponents), IntSize2D new(x, y))
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf?(This))
			result = (original as This) copy()
		else {
			result = This new(original size)
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
			(f as Closure) dispose()
		}
		result
	}

	// get the derivative on small window, region is window's global location on image, window is left top centered.
	getFirstDerivativeWindowOptimized: func (region: IntBox2D, imageX, imageY: FloatImage) {
		step := 2
		sourceWidth := this size width
		source := this buffer pointer + region leftTop y * sourceWidth // this getValue [x,y]
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
					8 * source[x + sourceWidth * step] -
					8 * source[x - sourceWidth * step] +
					source[x - sourceWidth * 2 * step] -
					source[x + sourceWidth * 2 * step]
				) as Float / (12.0f * step)
				destinationY += 1
			}
			source += sourceWidth
		}
	}
	// get the derivative on small window, region is window's global location on image, window is left top centered.
	getFirstDerivativeWindow: func (region: IntBox2D, imageX, imageY: FloatImage) {
		step := 3
		// Ix & Iy  centered difference approximation with 4th error order, centered window
		for (y in (region leftTop y) .. (region rightBottom y)) {
			for (x in (region leftTop x) .. (region rightBottom x)) {
				imageX[x - region leftTop x, y - region leftTop y] = (
					8 * this getValue(x + step, y) -
					8 * this getValue(x - step, y) +
					this getValue(x - 2 * step, y) -
					this getValue(x + 2 * step, y)
				) as Float / (12.0f * step)
			}
		}
		for (y in (region leftTop y) .. (region rightBottom y)) {
			for (x in (region leftTop x) .. (region rightBottom x)) {
				imageY[x - region leftTop x, y - region leftTop y] = (
					8 * this getValue(x, y + step) -
					8 * this getValue(x, y - step) +
					this getValue(x, y - 2 * step) -
					this getValue(x, y + 2 * step)
				) as Float / (12.0f * step)
			}
		}
	}
	operator [] (x, y: Int) -> ColorMonochrome {
		version(safe) {
			if (!this isValidIn(x, y))
				raise("Accessing RasterMonochrome index out of range in get operator")
		}
		ColorMonochrome new(this buffer pointer[y * this stride + x])
	}

	getValue: func (x, y: Int) -> UInt8 {
		version(safe) {
			if (x >= this size width || y >= this size height || x < 0 || y < 0)
				raise("Accessing RasterMonochrome index out of range in getValue")
		}
		(this buffer pointer[y * this stride + x])
	}

	operator []= (x, y: Int, value: ColorMonochrome) {
		version(safe) {
			if (x >= this size width || y >= this size height || x < 0 || y < 0)
				raise("Accessing RasterMonochrome index out of range in set operator")
		}
		((this buffer pointer + y * this stride) as ColorMonochrome* + x)@ = value
	}
	getRow: func (row: Int) -> FloatVectorList {
		result := FloatVectorList new(this size width)
		this getRowInto(row, result)
		result
	}
	getRowInto: func (row: Int, vector: FloatVectorList) {
		version(safe) {
			if (row >= this size height || row < 0)
				raise("Accessing RasterMonochrome index out of range in getRow")
		}
		for (column in 0 .. this size width)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	getColumn: func (column: Int) -> FloatVectorList {
		result := FloatVectorList new(this size height)
		this getColumnInto(column, result)
		result
	}
	getColumnInto: func (column: Int, vector: FloatVectorList) {
		version(safe) {
			if (column >= this size width || column < 0)
				raise("Accessing RasterMonochrome index out of range in getColumn")
		}
		for (row in 0 .. this size height)
			vector add(this buffer pointer[row * this stride + column] as Float)
	}
	createPaintEngine: override func -> PaintEngine { MonochromePaintEngine new(this) }
}
