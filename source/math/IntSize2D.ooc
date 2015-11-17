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
import FloatSize2D
import structs/ArrayList
use ooc-base

IntSize2D: cover {
	width, height: Int
	area ::= this width * this height
	square ::= this width == this height
	empty ::= !(this width > 0 && this height > 0)
	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }
	init: func@ (=width, =height)
	init: func@ ~square (length: Int) { this width = this height = length }
	init: func@ ~default { this init(0, 0) }
	scalarProduct: func (other: This) -> Int { this width * other width + this height * other height }
	swap: func -> This { This new(this height, this width) }
	minimum: func (ceiling: This) -> This { This new(Int minimum~two(this width, ceiling width), Int minimum~two(this height, ceiling height)) }
	maximum: func (floor: This) -> This { This new(Int maximum~two(this width, floor width), Int maximum~two(this height, floor height)) }
	minimum: func ~Int (ceiling: Int) -> This { this minimum(This new(ceiling)) }
	maximum: func ~Int (floor: Int) -> This { this maximum(This new(floor)) }
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
	toIntPoint2D: func -> IntPoint2D { IntPoint2D new(this width, this height) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}" }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toInt(), parts[1] toInt())
		parts free()
		result
	}
	kean_math_intSize2D_new: unmangled static func (width, height: Int) -> This { This new(width, height) }
}
operator * (left: Int, right: IntSize2D) -> IntSize2D { IntSize2D new(left * right width, left * right height) }
operator / (left: Int, right: IntSize2D) -> IntSize2D { IntSize2D new(left / right width, left / right height) }
operator * (left: Float, right: IntSize2D) -> IntSize2D { IntSize2D new(left * right width, left * right height) }
operator / (left: Float, right: IntSize2D) -> IntSize2D { IntSize2D new(left / right width, left / right height) }
