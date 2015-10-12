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
use ooc-collections
use ooc-math
import PaintEngine
import Image

/*
 this class uses the "Reference" coordinate system
 origin (0,0) is in the middle of the image
*/
Painter: class {
	_backend: PaintEngine
	init: func
	init: func ~withImage (image: Image) {
		this paintOn(image)
	}
	free: override func {
		if (this _backend)
			this _backend free()
		super()
	}
	paintOn: func (image: Image) {
		if (this _backend)
			this _backend free()
		this _backend = image createPaintEngine()
		version(safe) {
			if (this _backend == null)
				raise("Paint engine not implemented for " + image class name)
		}
	}
	drawPoint: func (x, y: Int) {
		this _backend drawPoint(x, y)
	}
	drawPoint: func ~withIntPoint2D (position: IntPoint2D) {
		this _backend drawPoint(position)
	}
	drawLine: func (start, end: IntPoint2D) {
		this _backend drawLine(start, end)
	}
	drawLine: func ~withCoordinates (x1, y1, x2, y2: Int) {
		this _backend drawLine(IntPoint2D new(x1, y1), IntPoint2D new(x2, y2))
	}
	drawBox: func (box: IntBox2D) {
		this _backend drawBox(box)
	}
	drawPoint: func ~withFloat (x, y: Float) {
		this _backend drawPoint(x, y)
	}
	drawPoint: func ~withFloatPoint2D (position: FloatPoint2D) {
		this _backend drawPoint(position)
	}
	drawLine: func ~withFloatPoint2D (start, end: FloatPoint2D) {
		this _backend drawLine(start, end)
	}
	drawLine: func ~withFloatCoordinates (x1, y1, x2, y2: Float) {
		this _backend drawLine(FloatPoint2D new(x1, y1), FloatPoint2D new(x2, y2))
	}
	drawLines: func (lines: VectorList<FloatPoint2D>) {
		this _backend drawLines(lines)
	}
	drawBox: func ~withFloatBox2D (box: FloatBox2D) {
		this _backend drawBox(box)
	}
	setPen: func (pen: Pen) {
		this _backend pen = pen
	}
}
