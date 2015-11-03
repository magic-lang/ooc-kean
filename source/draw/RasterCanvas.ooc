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
use ooc-math
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
			startX := Int minimum~two(start x, end x)
			endX := Int maximum~two(start x, end x)
			for (x in startX .. endX + 1)
				this _drawPoint(x, start y)
		} else if (start x == end x) {
			startY := Int minimum~two(start y, end y)
			endY := Int maximum~two(start y, end y)
			for (y in startY .. endY + 1)
				this _drawPoint(start x, y)
		} else {
			originalPen := this pen
			originalAlpha := originalPen alphaAsFloat
			slope := (end y - start y) as Float / (end x - start x) as Float
			startX := Int minimum~two(start x, end x)
			endX := Int maximum~two(start x, end x)
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
		IntPoint2D new(point x + this _size width / 2, point y + this _size height / 2)
	}
}
