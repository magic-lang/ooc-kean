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

use base
use geometry
use collections
import Image, Pen, DrawState

InterpolationMode: enum {
	Fast // nearest neighbour
	Smooth // bilinear
}

Canvas: abstract class {
	_size: IntVector2D
	_pen := Pen new()
	_transform := FloatTransform3D identity
	size ::= this _size
	pen: Pen { get { this _pen } set(value) { this _pen = value } }
	viewport: IntBox2D { get set }
	blend: Bool { get set }
	opacity: Float { get set }
	transform: FloatTransform3D { get { this _transform } set(value) { this _transform = value } }
	focalLength: Float { get set }
	interpolationMode: InterpolationMode { get set }
	init: func (=_size) {
		this viewport = IntBox2D new(size)
		this focalLength = 0.0f
		this blend = false
		this opacity = 1.0f
		this interpolationMode = InterpolationMode Fast
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
	draw: virtual func ~DrawState (drawState: DrawState) { Debug raise("draw~DrawState unimplemented!") }
	draw: abstract func ~ImageSourceDestination (image: Image, source, destination: IntBox2D)
	draw: func ~ImageDestination (image: Image, destination: IntBox2D) { this draw(image, IntBox2D new(image size), destination) }
	draw: func ~Image (image: Image) { this draw(image, IntBox2D new(image size)) }
	draw: func ~ImageTargetSize (image: Image, targetSize: IntVector2D) { this draw(image, IntBox2D new(targetSize)) }
}
