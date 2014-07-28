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
import FloatExtension
import FloatPoint2D
import text/StringTokenizer
import structs/ArrayList

FloatSize2D: cover {
	width, height: Float
	Area: Float { get { (this width * this height) } }
	Length: Float { get { this Norm } }
	Empty: Bool { get { this width == 0 || this height == 0 } }
	//Norm ::= (this width pow(2.0f) + this height pow(2.0f)) sqrt() // FIXME: Why does this syntax not work on a cover?
	Norm: Float { get { (this width pow(2.0f) + this height pow(2.0f)) sqrt() } }
	//Azimuth ::= this height atan2(this width) // FIXME: Why does this syntax not work on a cover?
	Azimuth: Float { get { this height atan2(this width) } }
	BasisX: static This { get { This new(1, 0) } }
	BasisY: static This { get { This new(0, 1) } }
	init: func@ (=width, =height)
	init: func ~default { this init(0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		p == 1 ?
		this width abs() + this height abs() :
		(this width abs() pow(p) + this height abs() pow(p)) pow(1 / p)
	}
	scalarProduct: func (other: This) -> Float { this width * other width + this height * other height }
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this Norm * other Norm)) clamp(-1.0f, 1.0f) acos() * (this width * other height - this height * other width < 0.0f ? -1.0f : 1.0f)
	}
	//FIXME: Oddly enough, "this - other" instead of "this + (-other)" causes a compile error in the unary '-' operator below.
	distance: func (other: This) -> Float { (this + (-other)) Norm }
	swap: func -> This { This new(this height, this width) }
	round: func -> This { This new(this width round(), this height round()) }
	ceiling: func -> This { This new(this width ceil(), this height ceil()) }
	floor: func -> This { This new(this width floor(), this height floor()) }
	minimum: func (ceiling: This) -> This { This new(this width minimum(ceiling width), this height minimum(ceiling height)) }
	maximum: func (floor: This) -> This { This new(this width maximum(floor width), this height maximum(floor height)) }
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
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}" }
	parse: static func(input: String) -> This {
		array := input split(',')
		This new (array[0] toFloat(), array[1] toFloat())
	}
}
operator * (left: Float, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left * right width, left * right height) }
operator / (left: Float, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left / right width, left / right height) }
operator * (left: Int, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left * right width, left * right height) }
operator / (left: Int, right: FloatSize2D) -> FloatSize2D { FloatSize2D new(left / right width, left / right height) }

