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
import Pen

InterpolationMode: enum {
	Fast // nearest neighbour
	Smooth // bilinear
}

BrushData: cover {
	viewport: IntBox2D
	pen: Pen
	transform: FloatTransform3D
	blend: Bool
	opacity: Float
	focalLength: Float
	interpolationMode: InterpolationMode
}

Brush: class {
	brushData: BrushData
	_size: IntVector2D
	size ::= this _size
	pen: Pen { get { this brushData pen } set(value) { this brushData pen = value } }
	viewport: IntBox2D { get { this brushData viewport } set(value) { this brushData viewport = value } }
	blend: Bool { get { this brushData blend } set(value) { this brushData blend = value } }
	opacity: Float { get { this brushData opacity } set(value) { this brushData opacity = value } }
	transform: FloatTransform3D { get { this brushData transform } set(value) { this brushData transform = value } }
	focalLength: Float { get { this brushData focalLength } set(value) { this brushData focalLength = value } }
	interpolationMode: InterpolationMode { get { this brushData interpolationMode } set(value) { this brushData interpolationMode = value } }
	init: func (=_size) {
		this viewport = IntBox2D new(size)
		this focalLength = 0.0f
		this blend = false
		this opacity = 1.0f
		this interpolationMode = InterpolationMode Fast
	}
}
