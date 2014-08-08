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
import math

CoordinateSystem: enum {
	Default = 0x00,
	XRightward = 0x00,
	XLeftward = 0x01,
	YDownward = 0x00,
	YUpward = 0x02
}

Image: abstract class {
	size: IntSize2D
	transform: IntTransform2D { get set }
	coordinateSystem: CoordinateSystem {
		get
		set (value) {
			if (this coordinateSystem != value) {
				this coordinateSystem = value
				this transform = IntTransform2D createScaling(
					(value & CoordinateSystem XLeftward) == CoordinateSystem XLeftward ? -1 : 1,
					(value & CoordinateSystem YUpward) == CoordinateSystem YUpward ? -1 : 1)
			}
		}
	}
	crop: IntShell2D {
		get
		set (value) {
			if (this crop != value)
				this crop = value
		}
	}
	wrap: Bool {
		get
		set (value) {
			if (this wrap != value)
				this wrap = value
		}
	}
	
	init: func (=size, .coordinateSystem, =crop, =wrap) { 
		this coordinateSystem = coordinateSystem
	}
	init: func ~fromImage (original: This) { this init(original size, original coordinateSystem, original crop, original wrap) }
	init: func ~default { 
		this transform = IntTransform2D Identity
	}
	resizeWithin: func (restriction: IntSize2D) -> This {
		this resizeTo(((this size asFloatSize2D()) * Float minimum(restriction width as Float / this size width as Float, restriction height as Float / this size height as Float)) asIntSize2D())
	}
	resizeTo: abstract func (size: IntSize2D) -> This
	create: abstract func (size: IntSize2D) -> This
	copy: abstract func -> This
	copy: abstract func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This
	shift: abstract func (offset: IntSize2D) -> This
	flush: func { }
	finish: func -> Bool { true }
	distance: abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
}
