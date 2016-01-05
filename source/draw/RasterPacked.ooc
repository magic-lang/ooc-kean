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

use ooc-geometry
use ooc-base
import io/File
import ByteBuffer
import StbImage
import RasterImage
import RasterBgra
import RasterBgr
import RasterMonochrome
import Image
import Canvas, RasterCanvas

RasterPackedCanvas: abstract class extends RasterCanvas {
	target ::= this _target as RasterPacked
	init: func (image: RasterPacked) { super(image) }
	_resizePacked: func <T> (sourceBuffer: T*, source: RasterPacked, sourceBox, resultBox: IntBox2D) {
		if (this target size == source size && this target stride == source stride && sourceBox == resultBox && sourceBox size == source size && sourceBox leftTop x == 0 && sourceBox leftTop y == 0 && source coordinateSystem == this target coordinateSystem)
			memcpy(this target buffer pointer, sourceBuffer, this target stride * this target height)
		else if (this interpolationMode == InterpolationMode Fast)
			This _resizeNearestNeighbour(sourceBuffer, this target buffer pointer as T*, source, this target, sourceBox, resultBox)
		else
			This _resizeBilinear(source, this target, sourceBox, resultBox)
	}
	_transformCoordinates: static func (column, row, width, height: Int, coordinateSystem: CoordinateSystem) -> (Int, Int) {
		if ((coordinateSystem & CoordinateSystem XLeftward) != 0)
			column = width - column - 1
		if ((coordinateSystem & CoordinateSystem YUpward) != 0)
			row = height - row - 1
		(column, row)
	}
	_resizeNearestNeighbour: static func <T> (sourceBuffer, resultBuffer: T*, source, target: RasterPacked, sourceBox, resultBox: IntBox2D) {
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStride, resultStride) := (source stride / bytesPerPixel, target stride / bytesPerPixel)
		sourceStartColumn := sourceBox leftTop x
		sourceStartRow := sourceBox leftTop y
		resultStartColumn := resultBox leftTop x
		resultStartRow := resultBox leftTop y
		for (row in 0 .. resultHeight) {
			sourceRow := (sourceHeight * row) / resultHeight + sourceStartRow
			for (column in 0 .. resultWidth) {
				sourceColumn := (sourceWidth * column) / resultWidth + sourceStartColumn
				(resultColumnTransformed, resultRowTransformed) := This _transformCoordinates(column + resultStartColumn, row + resultStartRow, target width, target height, target coordinateSystem)
				(sourceColumnTransformed, sourceRowTransformed) := This _transformCoordinates(sourceColumn, sourceRow, source width, source height, source coordinateSystem)
				resultBuffer[resultColumnTransformed + resultStride * resultRowTransformed] = sourceBuffer[sourceColumnTransformed + sourceStride * sourceRowTransformed]
			}
		}
	}
	_resizeBilinear: static func (source, target: RasterPacked, sourceBox, resultBox: IntBox2D) {
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStartColumn, sourceStartRow) := (sourceBox leftTop x, sourceBox leftTop y)
		(resultStartColumn, resultStartRow) := (resultBox leftTop x, resultBox leftTop y)
		(sourceStride, resultStride) := (source stride, target stride)
		(sourceBuffer, resultBuffer) := (source buffer pointer as UInt8*, target buffer pointer as UInt8*)
		for (row in 0 .. resultHeight) {
			sourceRow := ((sourceHeight as Float) * row) / resultHeight + sourceStartRow
			sourceRowUp := sourceRow floor() as Int
			weightDown := sourceRow - sourceRowUp as Float
			sourceRowDown := (sourceRow - weightDown) as Int + 1
			if (sourceRowDown >= sourceHeight)
				weightDown = 0.0f
			for (column in 0 .. resultWidth) {
				sourceColumn := ((sourceWidth as Float) * column) / resultWidth + sourceStartColumn
				sourceColumnLeft := sourceColumn floor() as Int
				weightRight := sourceColumn - sourceColumnLeft as Float
				if (sourceColumnLeft + 1 >= sourceWidth)
					weightRight = 0.0f
				(resultColumnTransformed, resultRowTransformed) := This _transformCoordinates(column + resultStartColumn, row + resultStartRow, target width, target height, target coordinateSystem)
				(sourceColumnLeftTransformed, sourceRowUpTransformed) := This _transformCoordinates(sourceColumnLeft, sourceRowUp, source width, source height, source coordinateSystem)
				(topLeft, topRight) := ((1.0f - weightDown) * (1.0f - weightRight), (1.0f - weightDown) * weightRight)
				(bottomLeft, bottomRight) := (weightDown * (1.0f - weightRight), weightDown * weightRight)
				This _blendSquare(sourceBuffer, resultBuffer, sourceStride, resultStride, sourceRowUpTransformed, sourceColumnLeftTransformed, resultRowTransformed, resultColumnTransformed, topLeft, topRight, bottomLeft, bottomRight, bytesPerPixel)
			}
		}
	}
	_blendSquare: static func (sourceBuffer, resultBuffer: UInt8*, sourceStride, resultStride, sourceRow, sourceColumn, row, column: Int, weightTopLeft, weightTopRight, weightBottomLeft, weightBottomRight: Float, bytesPerPixel: Int) {
		finalValue: UInt8 = 0
		for (i in 0 .. bytesPerPixel) {
			finalValue = weightTopLeft > 0.0f ? weightTopLeft * sourceBuffer[sourceColumn * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightTopRight > 0.0f ? weightTopRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightBottomLeft > 0.0f ? weightBottomLeft * sourceBuffer[sourceColumn * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			finalValue += weightBottomRight > 0.0f ? weightBottomRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			resultBuffer[column * bytesPerPixel + row * resultStride + i] = finalValue
		}
	}
}

RasterPacked: abstract class extends RasterImage {
	_buffer: ByteBuffer
	_stride: Int
	buffer ::= this _buffer
	stride ::= this _stride
	bytesPerPixel: Int { get }
	init: func (=_buffer, size: IntVector2D, =_stride) {
		super(size)
		this _buffer referenceCount increase()
	}
	init: func ~allocateStride (size: IntVector2D, stride: UInt) { this init(ByteBuffer new(stride * size y), size, stride) }
	init: func ~allocate (size: IntVector2D) {
		stride := this bytesPerPixel * size x
		this init(ByteBuffer new(stride * size y), size, stride)
	}
	init: func ~fromOriginal (original: This) {
		super(original)
		this _buffer = original buffer copy()
		this _stride = original stride
	}
	init: func ~fromRasterImage (original: RasterImage) {
		super(original)
		this _stride = this bytesPerPixel * original width
		this _buffer = ByteBuffer new(this stride * original height)
	}
	free: override func {
		if (this _buffer != null)
			this _buffer referenceCount decrease()
		this _buffer = null
		super()
	}
	equals: func (other: Image) -> Bool {
		other instanceOf?(This) && this bytesPerPixel == (other as This) bytesPerPixel && this as Image equals(other)
	}
	distance: virtual func (other: Image) -> Float {
		other instanceOf?(This) && this bytesPerPixel == (other as This) bytesPerPixel ? this as Image distance(other) : Float maximumValue
	}
	asRasterPacked: func (other: This) -> This {
		other
	}
	save: override func (filename: String) -> Int {
		file := File new(filename)
		folder := file parent . mkdirs() . free()
		file free()
		StbImage writePng(filename, this size x, this size y, this bytesPerPixel, this buffer pointer, this size x * this bytesPerPixel)
	}
	swapChannels: func (first, second: Int) {
		version(safe) {
			if (first > this bytesPerPixel || second > this bytesPerPixel)
				raise("Channel number too large")
		}
		pointer := this buffer pointer
		index := 0
		while (index < this buffer size) {
			value := pointer[index + first]
			pointer[index + first] = pointer[index + second]
			pointer[index + second] = value
			index += this bytesPerPixel
		}
	}
	kean_draw_rasterPacked_getData: unmangled func -> Void* { this buffer pointer }
	kean_draw_rasterPacked_getByteCount: unmangled func -> Int { this buffer size }
	kean_draw_rasterPacked_getStride: unmangled func -> Int { this stride }
	kean_draw_rasterPacked_copyData: unmangled func (destination: Char*) { memcpy(destination, this buffer pointer, this buffer size) }
}
