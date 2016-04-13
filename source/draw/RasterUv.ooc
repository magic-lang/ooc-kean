/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use draw
import RasterPacked
import RasterImage
import RasterRgb
import StbImage
import Image
import Color
import Pen
import Canvas, RasterCanvas

RasterUvCanvas: class extends RasterPackedCanvas {
	target ::= this _target as RasterUv
	init: func (image: RasterUv) { super(image) }
	_drawPoint: override func (x, y: Int, pen: Pen) {
		position := this _map(IntPoint2D new(x, y))
		if (this target isValidIn(position x, position y))
			this target[position x, position y] = this target[position x, position y] blend(pen alphaAsFloat, pen color toUv())
	}
	_draw: override func (image: Image, source, destination: IntBox2D, interpolate: Bool) {
		uv: RasterUv = null
		if (image == null)
			Debug error("Null image in RasterUvCanvas draw")
		else if (image instanceOf(RasterUv))
			uv = image as RasterUv
		else if (image instanceOf(RasterImage))
			uv = RasterUv convertFrom(image as RasterImage)
		else
			Debug error("Unsupported image type in RasterUvCanvas draw")
		this _resizePacked(uv buffer pointer as ColorUv*, uv, source, destination, interpolate)
		if (uv != image)
			uv referenceCount decrease()
	}
}

RasterUv: class extends RasterPacked {
	bytesPerPixel ::= 2
	init: func ~allocate (size: IntVector2D) { super~allocate(size) }
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { super(size, stride) }
	init: func ~fromByteBufferStride (buffer: ByteBuffer, size: IntVector2D, stride: UInt) { super(buffer, size, stride) }
	init: func ~fromByteBuffer (buffer: ByteBuffer, size: IntVector2D) { this init(buffer, size, this bytesPerPixel * size x) }
	init: func ~fromRasterUv (original: This) { super(original) }
	init: func ~fromRasterImage (original: RasterImage) { super(original) }
	create: override func (size: IntVector2D) -> Image { This new(size) }
	copy: override func -> This { This new(this) }
	apply: override func ~rgb (action: Func(ColorRgb)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: override func ~yuv (action: Func(ColorYuv)) {
		uvRow := this buffer pointer
		uSource := uvRow
		vRow := uvRow + 1
		vSource := vRow
		width := this size x
		height := this size y

		for (y in 0 .. height) {
			for (x in 0 .. width) {
				action(ColorYuv new(128, uSource@, vSource@))
				uSource += 2
				vSource += 2
			}
			uvRow += this stride
			uSource = uvRow
			vSource = uvRow + 1
		}
	}
	apply: override func ~monochrome (action: Func(ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
	}
	resizeTo: override func (size: IntVector2D) -> This {
		this resizeTo(size, true) as This
	}
	resizeTo: override func ~withMethod (size: IntVector2D, interpolate: Bool) -> This {
		result := This new(size)
		DrawState new(result) setInputImage(this) setInterpolate(interpolate) draw()
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
						for (otherY in 0 maximum(y - this distanceRadius) .. (y + 1 + this distanceRadius) minimum(this size y))
							for (otherX in 0 maximum(x - this distanceRadius) .. (x + 1 + this distanceRadius) minimum(this size x))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
									if (maximum u < pixel u)
										maximum u = pixel u
									else if (minimum u > pixel u)
										minimum u = pixel u
									if (maximum v < pixel v)
										maximum v = pixel v
									else if (minimum v > pixel v)
										minimum v = pixel v
								}
						distance := 0.0f
						if (c u < minimum u)
							distance += (minimum u - c u) as Float squared
						else if (c u > maximum u)
							distance += (c u - maximum u) as Float squared
						if (c v < minimum v)
							distance += (minimum v - c v) as Float squared
						else if (c v > maximum v)
							distance += (c v - maximum v) as Float squared
						result += (distance) sqrt() / 3
					}
				}
			result /= ((this size x squared + this size y squared) as Float sqrt())
		}
		result
	}
	_createCanvas: override func -> Canvas { RasterUvCanvas new(this) }

	operator [] (x, y: Int) -> ColorUv { this isValidIn(x, y) ? ((this buffer pointer + y * this stride) as ColorUv* + x)@ : ColorUv new(0, 0) }
	operator []= (x, y: Int, value: ColorUv) { ((this buffer pointer + y * this stride) as ColorUv* + x)@ = value }

	save: override func (filename: String) -> Int {
		rgb := RasterRgb convertFrom(this)
		result := rgb save(filename)
		rgb referenceCount decrease()
		result
	}
	open: static func (filename: String, coordinateSystem := CoordinateSystem Default) -> This {
		rasterRgb := RasterRgb open(filename, coordinateSystem)
		result := This convertFrom(rasterRgb)
		rasterRgb referenceCount decrease()
		result
	}
	convertFrom: static func (original: RasterImage) -> This {
		result: This
		if (original instanceOf(This))
			result = (original as This) copy()
		else {
			result = This new(original)
			row := result buffer pointer
			rowLength := result size x
			rowEnd := row as ColorUv* + rowLength
			destination := row as ColorUv*
			f := func (color: ColorYuv) {
				(destination as ColorUv*)@ = ColorUv new(color u, color v)
				destination += 1
				if (destination >= rowEnd) {
					row += result stride
					destination = row as ColorUv*
					rowEnd = row as ColorUv* + rowLength
				}
			}
			original apply(f)
			(f as Closure) free()
		}
		result
	}
}
