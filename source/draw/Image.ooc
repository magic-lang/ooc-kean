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
use ooc-base
import math

CoordinateSystem: enum {
	Default = 0x00,
	XRightward = 0x00,
	XLeftward = 0x01,
	YDownward = 0x00,
	YUpward = 0x02
}

Image: abstract class {
	_size: IntSize2D
	size ::= this _size
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
	crop: IntShell2D { get set }
	wrap: Bool { get set }
	_referenceCount: ReferenceCounter
	referenceCount ::= this _referenceCount
	init: func (=_size) {
		this _referenceCount = ReferenceCounter new(this)
		this coordinateSystem = CoordinateSystem Default
	}
	init: func ~fromImage (original: This) {
		this init(original size)
		this coordinateSystem = original coordinateSystem
		this crop = original crop
		this wrap = original wrap
	}
	__destroy__:func {
		this referenceCount
		if (this referenceCount != null)
			this referenceCount free()
		this _referenceCount = null
		super()
	}
	resizeWithin: func (restriction: IntSize2D) -> This {
		this resizeTo(((this size toFloatSize2D()) * Float minimum(restriction width as Float / this size width as Float, restriction height as Float / this size height as Float)) toIntSize2D())
	}
	resizeTo: abstract func (size: IntSize2D) -> This
	create: abstract func (size: IntSize2D) -> This
	copy: abstract func -> This
	copy: abstract func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This
//	shift: abstract func (offset: IntSize2D) -> This
	flush: func { }
	finish: func -> Bool { true }
	distance: virtual abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
	isValidIn: func (x, y: Int) -> Bool {
		return (x >= 0 && x < this size width && y >= 0 && y < this size height)
	}
}
