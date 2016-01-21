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
import Image, Brush

Canvas: abstract class extends Brush {
	_size: IntVector2D
	size ::= this _size
	init: func (=_size) {
		super(this _size)
	}
	drawPoint: virtual func (position: FloatPoint2D) {
		list := VectorList<FloatPoint2D> new()
		list add(position)
		this drawPoints(list)
		list free()
	}
	drawLine: virtual func (start, end: FloatPoint2D) {
		list := VectorList<FloatPoint2D> new()
		list add(start) . add(end)
		this drawLines(list)
		list free()
	}
	drawPoints: abstract func (pointList: VectorList<FloatPoint2D>)
	drawLines: abstract func (lines: VectorList<FloatPoint2D>)
	drawBox: virtual func (box: FloatBox2D) {
		positions := VectorList<FloatPoint2D> new()
		positions add(box leftTop)
		positions add(box rightTop)
		positions add(box rightBottom)
		positions add(box leftBottom)
		positions add(box leftTop)
		this drawLines(positions)
		positions free()
	}
	fill: abstract func
	draw: abstract func ~ImageSourceDestination (image: Image, source, destination: IntBox2D)
	draw: func ~ImageDestination (image: Image, destination: IntBox2D) { this draw(image, IntBox2D new(image size), destination) }
	draw: func ~Image (image: Image) { this draw(image, IntBox2D new(image size)) }
	draw: func ~ImageTargetSize (image: Image, targetSize: IntVector2D) { this draw(image, IntBox2D new(targetSize)) }
}
