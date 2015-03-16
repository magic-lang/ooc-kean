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
import IntPoint2D
import IntExtension
import FloatSize2D
import text/StringTokenizer
import structs/ArrayList

IntSize2D: cover {
	width, height: Int
	area ::= this width * this height
	empty ::= this width == 0 || this height == 0
	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }
	init: func@ (=width, =height)
	init: func@ ~default { this init(0, 0) }
	create: unmangled(kean_math_intSize2D_new) static func@ (width: Int, height: Int) { This new(width, height) }
	scalarProduct: func (other: This) -> Int { this width * other width + this height * other height }
	swap: func -> This { This new(this height, this width) }
	minimum: func (ceiling: This) -> This { This new(this width minimum(ceiling width), this height minimum(ceiling height)) }
	maximum: func (floor: This) -> This { This new(this width maximum(floor width), this height maximum(floor height)) }
	clamp: func (floor, ceiling: This) -> This { This new(this width clamp(floor width, ceiling width), this height clamp(floor height, ceiling height)) }
	fillEven: static func (other: This) -> This { This new(other width + (other width % 2 == 1 ? 1 : 0), other height + (other height % 2 == 1 ? 1 : 0)) }
	operator + (other: This) -> This { This new(this width + other width, this height + other height) }
	operator + (other: IntPoint2D) -> This { This new(this width + other x, this height + other y) }
	operator - (other: This) -> This { This new(this width - other width, this height - other height) }
	operator - (other: IntPoint2D) -> This { This new(this width - other x, this height - other y) }
	operator - -> This { This new(-this width, -this height) }
	operator * (other: This) -> This { This new(this width * other width, this height * other height) }
	operator * (other: IntPoint2D) -> This { This new(this width * other x, this height * other y) }
	operator / (other: This) -> This { This new(this width / other width, this height / other height) }
	operator / (other: IntPoint2D) -> This { This new(this width / other x, this height / other y) }
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
	polar: static func (radius, azimuth: Int) -> This { This new(radius * cos(azimuth), radius * sin(azimuth)) }
	toFloatSize2D: func -> FloatSize2D { FloatSize2D new(this width as Float, this height as Float) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}" }
	parse: static func(input: String) -> This {
		array := input split(',')
		This new (array[0] toInt(), array[1] toInt())
	}
}
operator * (left: Int, right: IntSize2D) -> IntSize2D { IntSize2D new(left * right width, left * right height) }
operator / (left: Int, right: IntSize2D) -> IntSize2D { IntSize2D new(left / right width, left / right height) }
operator * (left: Float, right: IntSize2D) -> IntSize2D { IntSize2D new(left * right width, left * right height) }
operator / (left: Float, right: IntSize2D) -> IntSize2D { IntSize2D new(left / right width, left / right height) }
