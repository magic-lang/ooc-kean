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

use ooc-math
use ooc-draw
use ooc-collections
use ooc-base

import GpuContext, GpuMap

GpuSurface: abstract class {
	clearColor: ColorBgra { get set }
	viewport: IntBox2D { get set }
	_size: IntSize2D
	size ::= this _size
	blend: Bool { get set }
	_context: GpuContext
	_model: FloatTransform3D
	_view: FloatTransform3D
	_projection: FloatTransform3D
	_toReference: FloatTransform3D
	_toLocal: FloatTransform3D
	transform: FloatTransform3D {
		get { this _toLocal * this _view * this _toReference }
		set(value) { this _view = this _toReference * value * this _toLocal }
	}
	_focalLength: Float
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			if (this _focalLength > 0.0f) {
				this _projection = FloatTransform3D new(2.0f * this _focalLength / this size width, 0.0f, 0.0f, 0.0f, 0.0f,
					2.0f * this _focalLength / this size height, 0.0f, 0.0f, 0.0f, 0.0f, -(this farPlane + this nearPlane) / (this farPlane - this nearPlane),
					-1.0f, 0.0f, 0.0f, -2.0f * this farPlane * this nearPlane / (this farPlane - this nearPlane), 0.0f)
			}
			else
				this _projection = FloatTransform3D createScaling(2.0f / this size width, 2.0f / this size height, 1.0f)
			this _model = this _createModelTransform(this size, IntTransform2D identity)
		}
	}
	nearPlane: Float { get set }
	farPlane: Float { get set }
	map: GpuMap { get set }
	_defaultMap: GpuMap
	init: func (=_size, =_context, =_defaultMap) { this reset() }
	_createModelTransform: func (size: IntSize2D, coordinateTransform: IntTransform2D) -> FloatTransform3D {
		FloatTransform3D createTranslation(0.0f, 0.0f, -this focalLength) * FloatTransform3D createScaling(coordinateTransform a * size width / 2.0f, coordinateTransform e * size height / 2.0f, 1.0f)
	}
	reset: virtual func {
		this _toLocal = FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		this _toReference = this _toLocal inverse
		this clearColor = ColorBgra new(0, 0, 0, 0)
		this viewport = IntBox2D new(this size)
		this focalLength = 0.0f
		this nearPlane = 1.0f
		this farPlane = 10000.0f
		this _view = FloatTransform3D identity
		this blend = false
		this map = this _defaultMap
	}
	_bind: virtual func
	_unbind: virtual func
	clear: abstract func
	draw: func ~general (action: Func) {
		this _bind()
		this _context setViewport(this viewport)
		this _context enableBlend(this blend)
		this map use()
		action()
		this _unbind()
		this reset()
	}
	draw: abstract func (image: Image)
	drawLines: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawLines(pointList, this _projection * this _toLocal) }) }
	drawBox: virtual func (box: FloatBox2D) { this draw(func { this _context drawBox(box, this _projection * this _toLocal) }) }
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawPoints(pointList, this _projection * this _toLocal) }) }
}
