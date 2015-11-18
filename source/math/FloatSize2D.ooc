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
import FloatPoint2D
import IntSize2D
use ooc-base

FloatSize2D: cover {
	width, height: Float
	area ::= this width * this height
	length ::= this norm
	empty ::= !(this width > 0 && this height > 0)
	norm ::= (this width squared() + this height squared()) sqrt()
	azimuth ::= this height atan2(this width)
	absolute ::= This new(Float absolute(this width), Float absolute(this height))
	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }
	init: func@ (=width, =height)
	init: func@ ~square (length: Float) { this width = this height = length }
	init: func@ ~default { this init(0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this width abs() pow(p) + this height abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this width * other width + this height * other height }
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1.0f, 1.0f) acos() * (this width * other height - this height * other width < 0.0f ? -1.0f : 1.0f)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	swap: func -> This { This new(this height, this width) }
	round: func -> This { This new(this width round(), this height round()) }
	ceiling: func -> This { This new(this width ceil(), this height ceil()) }
	floor: func -> This { This new(this width floor(), this height floor()) }
	minimum: func (ceiling: This) -> This { This new(Float minimum(this width, ceiling width), Float minimum(this height, ceiling height)) }
	maximum: func (floor: This) -> This { This new(Float maximum(this width, floor width), Float maximum(this height, floor height)) }
	minimum: func ~Float (ceiling: Float) -> This { this minimum(This new(ceiling)) }
	maximum: func ~Float (floor: Float) -> This { this maximum(This new(floor)) }
	clamp: func (floor, ceiling: This) -> This { This new(this width clamp(floor width, ceiling width), this height clamp(floor height, ceiling height)) }
	operator + (other: This) -> This { This new(this width + other width, this height + other height) }
	operator + (other: FloatPoint2D) -> This { This new(this width + other x, this height + other y) }
	operator - (other: This) -> This { This new(this width - other width, this height - other height) }
	operator - (other: FloatPoint2D) -> This { This new(this width - other x, this height - other y) }
	operator - -> This { This new(-this width, -this height) }
	operator * (other: This) -> This { This new(this width * other width, this height * other height) }
	operator * (other: FloatPoint2D) -> This { This new(this width * other x, this height * other y) }
	operator / (other: This) -> This { This new(this width / other width, this height / other height) }
	operator / (other: FloatPoint2D) -> This { This new(this width / other x, this height / other y) }
	operator * (other: Float) -> This { This new(this width * other, this height * other) }
	operator / (other: Float) -> This { This new(this width / other, this height / other) }
	operator * (other: Int) -> This { This new(this width * other, this height * other) }
	operator / (other: Int) -> This { This new(this width / other, this height / other) }
	operator == (other: This) -> Bool { this width == other width && this height == other height }
	operator != (other: This) -> Bool { !(this == other) }
	operator < (other: This) -> Bool { this width < other width && this height < other height }
	operator > (other: This) -> Bool { this width > other width && this height > other height }
	operator <= (other: This) -> Bool { this width <= other width && this height <= other height }
	operator >= (other: This) -> Bool { this width >= other width && this height >= other height }
	polar: static func (radius, azimuth: Float) -> This { This new(radius * cos(azimuth), radius * sin(azimuth)) }
	toIntSize2D: func -> IntSize2D { IntSize2D new(this width as Int, this height as Int) }
	toFloatPoint2D: func -> FloatPoint2D { FloatPoint2D new(this width, this height) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}" }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toFloat(), parts[1] toFloat())
		parts free()
		result
	}
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(Float linearInterpolation(a width, b width, ratio), Float linearInterpolation(a height, b height, ratio))
	}
}
operator * (left: Float, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left * right width, left * right height) }
operator / (left: Float, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left / right width, left / right height) }
operator * (left: Int, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left * right width, left * right height) }
operator / (left: Int, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left / right width, left / right height) }
