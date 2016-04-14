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
use draw
import Image
import Pen
import DrawState

Canvas: abstract class {
	_size: IntVector2D
	size ::= this _size
	init: func (=_size)
	drawPoint: virtual func ~white (position: FloatPoint2D) { this drawPoint(position, Pen new(ColorRgba white)) }
	drawPoint: virtual func ~explicit (position: FloatPoint2D, pen: Pen) {
		list := VectorList<FloatPoint2D> new()
		list add(position)
		this drawPoints(list, pen)
		list free()
	}
	drawLine: virtual func ~white (start, end: FloatPoint2D) { this drawLine(start, end, Pen new(ColorRgba white)) }
	drawLine: virtual func ~explicit (start, end: FloatPoint2D, pen: Pen) {
		list := VectorList<FloatPoint2D> new()
		list add(start) . add(end)
		this drawLines(list, pen)
		list free()
	}
	drawPoints: func ~white (pointList: VectorList<FloatPoint2D>) { this drawPoints(pointList, Pen new(ColorRgba white)) }
	drawPoints: abstract func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen)
	drawLines: func ~white (pointList: VectorList<FloatPoint2D>) { this drawLines(pointList, Pen new(ColorRgba white)) }
	drawLines: abstract func ~explicit (lines: VectorList<FloatPoint2D>, pen: Pen)
	drawBox: virtual func ~white (box: FloatBox2D) { this drawBox(box, Pen new(ColorRgba white)) }
	drawBox: virtual func ~explicit (box: FloatBox2D, pen: Pen) {
		positions := VectorList<FloatPoint2D> new()
		positions add(box leftTop)
		positions add(box rightTop)
		positions add(box rightBottom)
		positions add(box leftBottom)
		positions add(box leftTop)
		this drawLines(positions, pen)
		positions free()
	}
	fill: abstract func (color: ColorRgba)
	draw: virtual func ~DrawState (drawState: DrawState) { Debug error("draw~DrawState unimplemented for class " + this class name + "!") }
}
