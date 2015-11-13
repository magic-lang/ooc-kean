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
import Canvas

CoordinateSystem: enum {
	Default = 0x00,
	XRightward = 0x00,
	XLeftward = 0x01,
	YDownward = 0x00,
	YUpward = 0x02
}

InterpolationMode: enum {
	Fast, // nearest neighbour
	Smooth // bilinear
}

Image: abstract class {
	_size: IntSize2D
	size ::= this _size
	width ::= this size width
	height ::= this size height
	coordinateSystem: CoordinateSystem { get set }
	crop: IntShell2D { get set }
	wrap: Bool { get set }
	_referenceCount: ReferenceCounter
	referenceCount ::= this _referenceCount
	transform ::= IntTransform2D createScaling(
			(this coordinateSystem & CoordinateSystem XLeftward) == CoordinateSystem XLeftward ? -1 : 1,
			(this coordinateSystem & CoordinateSystem YUpward) == CoordinateSystem YUpward ? -1 : 1)

	_canvas: Canvas
	canvas: Canvas {
		get {
			if (this _canvas == null)
				this _canvas = this _createCanvas()
			this _canvas
		}
	}
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
	free: override func {
		if (this referenceCount != null)
			this referenceCount free()
		this _referenceCount = null
		if (this _canvas != null)
			this _canvas free()
		this _canvas = null
		super()
	}
	resizeWithin: func (restriction: IntSize2D) -> This {
		this resizeTo(((this size toFloatSize2D()) * Float minimum(restriction width as Float / this size width as Float, restriction height as Float / this size height as Float)) toIntSize2D())
	}
	resizeTo: abstract func (size: IntSize2D) -> This
	resizeTo: virtual func ~withMethod (size: IntSize2D, method: InterpolationMode) -> This {
		this resizeTo(size)
	}
	create: virtual func (size: IntSize2D) -> This { raise("Image type not implemented."); null }
	copy: abstract func -> This
	copy: abstract func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This
	distance: virtual abstract func (other: This) -> Float
	equals: func (other: This) -> Bool { this size == other size && this distance(other) < 10 * Float epsilon }
	isValidIn: func (x, y: Int) -> Bool {
		return (x >= 0 && x < this size width && y >= 0 && y < this size height)
	}
	_createCanvas: virtual func -> Canvas { null }
	kean_draw_image_free: unmangled func { this referenceCount decrease() }
}
