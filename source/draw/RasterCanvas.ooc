/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use collections
import Image
import Canvas
import Pen
import DrawState
import RasterImage

RasterCanvas: abstract class extends Canvas {
	_target: RasterImage
	init: func (=_target) { super(this _target size) }
	fill: override func { raise("RasterCanvas fill unimplemented!") }
	drawPoint: override func (point: FloatPoint2D) { this _drawPoint(point x as Int, point y as Int) }
	_drawPoint: abstract func (x, y: Int)
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) {
		for (i in 0 .. pointList count)
			this drawPoint(pointList[i])
	}
	_drawLine: func (start, end: IntPoint2D) {
		if (start y == end y) {
			startX := start x minimum(end x)
			endX := start x maximum(end x)
			for (x in startX .. endX + 1)
				this _drawPoint(x, start y)
		} else if (start x == end x) {
			startY := start y minimum(end y)
			endY := start y maximum(end y)
			for (y in startY .. endY + 1)
				this _drawPoint(start x, y)
		} else {
			originalPen := this pen
			originalAlpha := originalPen alphaAsFloat
			slope := (end y - start y) as Float / (end x - start x) as Float
			startX := start x minimum(end x)
			endX := start x maximum(end x)
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
}
