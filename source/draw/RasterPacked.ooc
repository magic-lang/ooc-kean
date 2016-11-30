/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import io/File
import ByteBuffer
import StbImage
import RasterImage
import RasterRgb
import RasterRgba
import RasterMonochrome
import Image

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
	init: func ~allocateStride (size: IntVector2D, stride: UInt) {
		this init(ByteBuffer new(stride * size y), size, stride)
		this _buffer zero()
	}
	init: func ~allocate (size: IntVector2D) {
		thisStride := this bytesPerPixel * size x
		this init(ByteBuffer new(thisStride * size y), size, thisStride)
	}
	free: override func {
		if (this _buffer != null)
			this _buffer referenceCount decrease()
		this _buffer = null
		super()
	}
	_resizePacked: func <T> (sourceBuffer: T*, source: This, sourceBox, resultBox: IntBox2D, transform: FloatTransform3D, interpolate, flipX, flipY: Bool, nullPixel: T) {
		version(safe)
			Debug error(transform determinant equals(0.0f), "invalid transform in _resizePacked!")
		if (transform == FloatTransform3D identity && this size == source size && this stride == source stride && sourceBox == resultBox && sourceBox size == source size && sourceBox leftTop x == 0 && sourceBox leftTop y == 0 && !flipX && !flipY)
			memcpy(this buffer pointer, sourceBuffer, this stride * this height)
		else if (interpolate)
			This _resizeBilinear(source, this, sourceBox, resultBox, transform, flipX, flipY, nullPixel)
		else
			This _resizeNearestNeighbour(sourceBuffer, this buffer pointer as T*, source, this, sourceBox, resultBox, transform, flipX, flipY, nullPixel)
	}
	_transformCoordinates: static func (column, row, width, height: Int, flipX, flipY: Bool) -> (Int, Int) {
		if (flipX)
			column = width - column - 1
		if (flipY)
			row = height - row - 1
		(column, row)
	}
	_resizeNearestNeighbour: static func <T> (sourceBuffer, resultBuffer: T*, source, target: This, sourceBox, resultBox: IntBox2D, transform: FloatTransform3D, flipX, flipY: Bool, nullPixel: T) {
		invertedTransform := transform inverse
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStride, resultStride) := (source stride / bytesPerPixel, target stride / bytesPerPixel)
		sourceStartColumn := sourceBox leftTop x
		sourceStartRow := sourceBox leftTop y
		resultStartColumn := resultBox leftTop x
		resultStartRow := resultBox leftTop y
		imageBox := IntBox2D new(source size)
		for (row in 0 .. resultHeight) {
			sourceRow := (sourceHeight * row) / resultHeight + sourceStartRow
			for (column in 0 .. resultWidth) {
				sourceColumn := (sourceWidth * column) / resultWidth + sourceStartColumn
				(resultColumnTransformed, resultRowTransformed) := (column + resultStartColumn, row + resultStartRow)
				(sourceColumnTransformed, sourceRowTransformed) := This _transformCoordinates(sourceColumn, sourceRow, source width, source height, flipX, flipY)
				mappedCoord := invertedTransform * FloatPoint3D new(sourceColumnTransformed, sourceRowTransformed, 1.0)
				if (imageBox contains(IntPoint2D new(mappedCoord x, mappedCoord y)))
					resultBuffer[resultColumnTransformed + resultStride * resultRowTransformed] = sourceBuffer[mappedCoord x as Int + sourceStride * mappedCoord y as Int]
				else
					resultBuffer[resultColumnTransformed + resultStride * resultRowTransformed] = nullPixel
			}
		}
	}
	_resizeBilinear: static func <T> (source, target: This, sourceBox, resultBox: IntBox2D, transform: FloatTransform3D, flipX, flipY: Bool, nullPixel: T) {
		invertedTransform := transform inverse
		bytesPerPixel := target bytesPerPixel
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStartColumn, sourceStartRow) := (sourceBox leftTop x, sourceBox leftTop y)
		(resultStartColumn, resultStartRow) := (resultBox leftTop x, resultBox leftTop y)
		(sourceStride, resultStride) := (source stride, target stride)
		(sourceBuffer, resultBuffer) := (source buffer pointer as T*, target buffer pointer as T*)
		imageBox := IntBox2D new(source size)
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
				(resultColumnTransformed, resultRowTransformed) := (column + resultStartColumn, row + resultStartRow)
				(sourceColumnTransformed, sourceRowTransformed) := This _transformCoordinates(sourceColumn, sourceRow, source width, source height, flipX, flipY)
				mappedCoord3D := invertedTransform * FloatPoint3D new(sourceColumnTransformed, sourceRowTransformed, 1.0)
				mappedCoord := IntPoint2D new(mappedCoord3D x, mappedCoord3D y)
				if (imageBox contains(mappedCoord)) {
					if (mappedCoord x == sourceBox width - 1)
						mappedCoord x = mappedCoord x - 1
					if (mappedCoord y == sourceBox height - 1)
						mappedCoord y = mappedCoord y - 1
					(topLeft, topRight) := ((1.0f - weightDown) * (1.0f - weightRight), (1.0f - weightDown) * weightRight)
					(bottomLeft, bottomRight) := (weightDown * (1.0f - weightRight), weightDown * weightRight)
					This _blendSquare(sourceBuffer as Byte*, resultBuffer as Byte*, sourceStride, resultStride, mappedCoord y, mappedCoord x, resultRowTransformed, resultColumnTransformed, topLeft, topRight, bottomLeft, bottomRight, bytesPerPixel)
				} else
					resultBuffer[resultColumnTransformed + (resultStride / bytesPerPixel) * resultRowTransformed] = nullPixel
			}
		}
	}
	_blendSquare: static func (sourceBuffer, resultBuffer: Byte*, sourceStride, resultStride, sourceRow, sourceColumn, row, column: Int, weightTopLeft, weightTopRight, weightBottomLeft, weightBottomRight: Float, bytesPerPixel: Int) {
		finalValue: Byte = 0
		for (i in 0 .. bytesPerPixel) {
			finalValue = weightTopLeft > 0.0f ? weightTopLeft * sourceBuffer[sourceColumn * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightTopRight > 0.0f ? weightTopRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + sourceRow * sourceStride + i] : 0
			finalValue += weightBottomLeft > 0.0f ? weightBottomLeft * sourceBuffer[sourceColumn * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			finalValue += weightBottomRight > 0.0f ? weightBottomRight * sourceBuffer[(sourceColumn + 1) * bytesPerPixel + (sourceRow + 1) * sourceStride + i] : 0
			resultBuffer[column * bytesPerPixel + row * resultStride + i] = finalValue
		}
	}
	equals: func (other: Image) -> Bool { other instanceOf(This) && this bytesPerPixel == (other as This) bytesPerPixel && this as Image equals(other) }
	distance: override func (other: Image) -> Float {
		other instanceOf(This) && this bytesPerPixel == (other as This) bytesPerPixel ? this as Image distance(other) : Float maximumValue
	}
	asRasterPacked: func (other: This) -> This { other }
	save: override func (filename: String) -> Int {
		File createParentDirectories(filename)
		StbImage writePng(filename, this size x, this size y, this bytesPerPixel, this buffer pointer, this stride)
	}
	swapChannels: func (first, second: Int) {
		version(safe)
			Debug error(first > this bytesPerPixel || second > this bytesPerPixel, "Channel number too large")
		pointer := this buffer pointer
		index := 0
		while (index < this buffer size) {
			value := pointer[index + first]
			pointer[index + first] = pointer[index + second]
			pointer[index + second] = value
			index += this bytesPerPixel
		}
	}
}
