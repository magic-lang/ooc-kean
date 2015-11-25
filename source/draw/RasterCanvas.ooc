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

use ooc-base
use ooc-geometry
use ooc-collections
import math
import Image, Canvas, Pen, RasterImage

RasterCanvas: abstract class extends Canvas {
	_target: RasterImage
	init: func (=_target) { super(this _target size) }
	fill: override func { raise("RasterCanvas fill unimplemented!") }
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) { Debug raise("RasterCanvas draw~ImageSourceDestination unimplemented!") }
	drawPoint: override func (point: FloatPoint2D) { this _drawPoint(point x as Int, point y as Int) }
	_drawPoint: abstract func (x, y: Int)
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) {
		for (i in 0 .. pointList count)
			this drawPoint(pointList[i])
	}
	_drawLine: func (start, end: IntPoint2D) {
		if (start y == end y) {
			startX := Int minimum(start x, end x)
			endX := Int maximum(start x, end x)
			for (x in startX .. endX + 1)
				this _drawPoint(x, start y)
		} else if (start x == end x) {
			startY := Int minimum(start y, end y)
			endY := Int maximum(start y, end y)
			for (y in startY .. endY + 1)
				this _drawPoint(start x, y)
		} else {
			originalPen := this pen
			originalAlpha := originalPen alphaAsFloat
			slope := (end y - start y) as Float / (end x - start x) as Float
			startX := Int minimum(start x, end x)
			endX := Int maximum(start x, end x)
			for (x in startX .. endX + 1) {
				idealY := slope * (x - start x) + start y
				floor := idealY floor()
				weight := (idealY - floor) abs()
				this pen setAlpha(originalAlpha * (1.0f - weight))
				this _drawPoint(x, floor)
				this pen setAlpha(originalAlpha * weight)
				this _drawPoint(x, floor + 1)
			}
			this pen = originalPen
		}
	}
	drawLines: override func (lines: VectorList<FloatPoint2D>) {
		if (lines count > 1)
			for (i in 0 .. lines count - 1) {
				start := IntPoint2D new(lines[i] x, lines[i] y)
				end := IntPoint2D new(lines[i + 1] x, lines[i + 1] y)
				this _drawLine(start, end)
			}
	}
	_map: func (point: IntPoint2D) -> IntPoint2D {
		point + this _size / 2
	}
	resizeNearestNeighbour: static func <T> (sourceBuffer, resultBuffer: T*, sourceBox, resultBox: IntBox2D, sourceStride, resultStride, bytesPerPixel: Int) {
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		sourceStride /= bytesPerPixel
		resultStride /= bytesPerPixel
		sourceStartColumn := sourceBox leftTop x
		sourceStartRow := sourceBox leftTop y
		resultStartColumn := resultBox leftTop x
		resultStartRow := resultBox leftTop y
		for (row in 0 .. resultHeight) {
			sourceRow := (sourceHeight * row) / resultHeight + sourceStartRow
			for (column in 0 .. resultWidth) {
				sourceColumn := (sourceWidth * column) / resultWidth + sourceStartColumn
				resultBuffer[(column + resultStartColumn) + resultStride * (row + resultStartRow)] = sourceBuffer[sourceColumn + sourceStride * sourceRow]
			}
		}
	}
	resizeBilinear: static func <T> (sourceBuffer, resultBuffer: T*, sourceBox, resultBox: IntBox2D, sourceStride, resultStride, bytesPerPixel: Int) {
		(resultWidth, resultHeight) := (resultBox size x, resultBox size y)
		(sourceWidth, sourceHeight) := (sourceBox size x, sourceBox size y)
		(sourceStartColumn, sourceStartRow) := (sourceBox leftTop x, sourceBox leftTop y)
		(resultStartColumn, resultStartRow) := (resultBox leftTop x, resultBox leftTop y)
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
				This _blendSquare(sourceBuffer as UInt8*, resultBuffer as UInt8*, sourceStride, resultStride, sourceRowUp, sourceColumnLeft, row + resultStartRow, column + resultStartColumn, (1.0f - weightDown) * (1.0f - weightRight), (1.0f - weightDown) * weightRight, weightDown * (1.0f - weightRight), weightDown * weightRight, bytesPerPixel)
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
