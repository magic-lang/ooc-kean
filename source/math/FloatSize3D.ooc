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
import math
import FloatPoint3D
import IntPoint3D
import IntSize3D
import structs/ArrayList

FloatSize3D: cover {
	width, height, depth: Float
	volume ::= this width * this height * this depth
	length ::= this norm
	empty ::= this width == 0 || this height == 0 || this depth == 0
	norm ::= (this width squared() + this height squared() + this depth squared()) sqrt()
	azimuth ::= this height atan2(this width)
	basisX: static This { get { This new(1, 0, 0) } }
	basisY: static This { get { This new(0, 1, 0) } }
	basisZ: static This { get { This new(0, 0, 1) } }
	init: func@ (=width, =height, =depth)
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		p == 1 ?
		this width abs() + this height abs() :
		(this width abs() pow(p) + this height abs() pow(p)) pow(1 / p)
	}
	scalarProduct: func (other: This) -> Float { this width * other width + this height * other height + this depth * other depth }
	vectorProduct: func (other: This) -> This {
		This new(
			this height * other depth - other height * this depth,
			-(this width * other depth - other width * this depth),
			this width * other height - other width * this height
		)
	}
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1.0f, 1.0f) acos() * (this width * other height - this height * other width < 0.0f ? -1.0f : 1.0f)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	round: func -> This { This new(this width round(), this height round(), this depth round()) }
	ceiling: func -> This { This new(this width ceil(), this height ceil(), this depth ceil()) }
	floor: func -> This { This new(this width floor(), this height floor(), this height floor()) }
	minimum: func (ceiling: This) -> This { This new(Float minimum(this width, ceiling width), Float minimum(this height, ceiling height), Float minimum(this depth, ceiling depth)) }
	maximum: func (floor: This) -> This { This new(Float maximum(this width, floor width), Float maximum(this height, floor height), Float maximum(this depth, floor depth)) }
	clamp: func (floor, ceiling: This) -> This {
		This new(this width clamp(floor width, ceiling width), this height clamp(floor height, ceiling height), this depth clamp(floor depth, ceiling depth))
	}
	operator + (other: This) -> This { This new(this width + other width, this height + other height, this depth + other depth) }
	operator - (other: This) -> This { This new(this width - other width, this height - other height, this depth - other depth) }
	operator - -> This { This new(-this width, -this height, -this depth) }
	operator * (other: This) -> This { This new(this width * other width, this height * other height, this depth * other depth) }
	operator / (other: This) -> This { This new(this width / other width, this height / other height, this depth / other depth) }
	operator * (other: Float) -> This { This new(this width * other, this height * other, this depth * other) }
	operator / (other: Float) -> This { This new(this width / other, this height / other, this depth / other) }
	operator * (other: Int) -> This { This new(this width * other, this height * other, this depth * other) }
	operator / (other: Int) -> This { This new(this width / other, this height / other, this depth / other) }
	operator == (other: This) -> Bool { this width == other width && this height == other height && this depth == other depth }
	operator != (other: This) -> Bool { !(this == other) }
	operator < (other: This) -> Bool { this width < other width && this height < other height && this depth < other depth }
	operator > (other: This) -> Bool { this width > other width && this height > other height && this depth > other depth }
	operator <= (other: This) -> Bool { this width <= other width && this height <= other height && this depth <= other depth }
	operator >= (other: This) -> Bool { this width >= other width && this height >= other height && this depth >= other depth }
	toIntSize3D: func -> IntSize3D { IntSize3D new(this width as Int, this height as Int, this depth as Int) }
	toFloatPoint3D: func -> FloatPoint3D { FloatPoint3D new(this width, this height, this depth) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}, #{this depth toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new (array[0] toFloat(), array[1] toFloat(), array[2] toFloat())
	}
}
operator * (left: Float, right: FloatSize3D) -> FloatSize3D { FloatSize3D new(left * right width, left * right height, left * right depth) }
operator / (left: Float, right: FloatSize3D) -> FloatSize3D { FloatSize3D new(left / right width, left / right height, left / right depth) }
operator * (left: Int, right: FloatSize3D) -> FloatSize3D { FloatSize3D new(left * right width, left * right height, left * right depth) }
operator / (left: Int, right: FloatSize3D) -> FloatSize3D { FloatSize3D new(left / right width, left / right height, left / right depth) }
