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
import math
import Color

Pen: cover {
	color: ColorBgra { get set }
	alpha ::= this color alpha
	alphaAsFloat ::= this alpha as Float / 255.0f
	init: func@ (=color)
	init: func@ ~withBgr (colorBgr: ColorBgr) {
		this color = colorBgr toBgra()
	}
	setApha: func@ (alpha: UInt8) {
		this color = ColorBgra new(this color toBgr(), alpha)
	}
	setAlpha: func@ ~withFloat (value: Float) {
		this color = ColorBgra new(this color toBgr(), value * 255)
	}
}

PaintEngine: abstract class {
	pen: Pen { get set }
	init: func {
		this pen = Pen new(ColorBgra new(255, 255, 255, 255))
	}
	drawPoint: abstract func (x, y: Int)
	drawPoint: virtual func ~withIntPoint2D (position: IntPoint2D) {
		this drawPoint(position x, position y)
	}
	drawPoint: virtual func ~withFloat (x, y: Float) {
		this drawPoint(x as Int, y as Int)
	}
	drawPoint: virtual func ~withFloatPoint2D (position: FloatPoint2D) {
		this drawPoint(position toIntPoint2D())
	}
	drawLine: virtual func (start, end: IntPoint2D) {
		if (start y == end y) {
			startX := Int minimum~two(start x, end x)
			endX := Int maximum~two(start x, end x)
			for (x in startX .. endX + 1)
				this drawPoint(x, start y)
		} else if (start x == end x) {
			startY := Int minimum~two(start y, end y)
			endY := Int maximum~two(start y, end y)
			for (y in startY .. endY + 1)
				this drawPoint(start x, y)
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
				this drawPoint(x, floor)
				this pen setAlpha(originalAlpha * weight)
				this drawPoint(x, floor + 1)
			}
			this pen = originalPen
		}
	}
	drawLine: virtual func ~withFloatPoint2D (start, end: FloatPoint2D) {
		this drawLine(start toIntPoint2D(), end toIntPoint2D())
	}
	drawLines: virtual func (lines: VectorList<FloatPoint2D>) {
		if (lines count > 1)
			for (i in 0 .. lines count - 1)
				this drawLine(lines[i], lines[i + 1])
	}
	drawBox: virtual func (box: IntBox2D) {
		this drawLine(box leftTop, box rightTop)
		this drawLine(box rightTop, box rightBottom)
		this drawLine(box rightBottom, box leftBottom)
		this drawLine(box leftBottom, box leftTop)
	}
	drawBox: virtual func ~withFloatBox2D (box: FloatBox2D) {
		this drawBox(box toIntBox2D())
	}
}
