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
import IntPoint3D
import FloatSize3D
import structs/ArrayList

IntSize3D: cover {
	width, height, depth: Int
	volume ::= this width * this height * this depth
	empty ::= this width == 0 || this height == 0 || this depth == 0
	basisX: static This { get { This new(1, 0, 0) } }
	basisY: static This { get { This new(0, 1, 0) } }
	basisZ: static This { get { This new(0, 0, 1) } }
	init: func@ (=width, =height, =depth)
	init: func@ ~default { this init(0, 0, 0) }
	scalarProduct: func (other: This) -> Int { this width * other width + this height * other height + this depth * other depth }
	minimum: func (ceiling: This) -> This { This new(Int minimum~two(this width, ceiling width), Int minimum~two(this height, ceiling height), Int minimum~two(this depth, ceiling depth)) }
	maximum: func (floor: This) -> This { This new(Int maximum~two(this width, floor width), Int maximum~two(this height, floor height), Int maximum~two(this depth, floor depth)) }
	clamp: func (floor, ceiling: This) -> This { This new(this width clamp(floor width, ceiling width), this height clamp(floor height, ceiling height), this depth clamp(floor depth, ceiling depth)) }
	fillEven: static func (other: This) -> This { This new(other width + (other width % 2 == 1 ? 1 : 0), other height + (other height % 2 == 1 ? 1 : 0), other depth + (other depth % 2 == 1 ? 1 : 0)) }
	operator + (other: This) -> This { This new(this width + other width, this height + other height, this depth + other depth) }
	operator + (other: IntPoint3D) -> This { This new(this width + other x, this height + other y, this depth + other z) }
	operator - (other: This) -> This { This new(this width - other width, this height - other height, this depth - other depth) }
	operator - (other: IntPoint3D) -> This { This new(this width - other x, this height - other y, this depth - other z) }
	operator - -> This { This new(-this width, -this height, -this depth) }
	operator * (other: This) -> This { This new(this width * other width, this height * other height, this depth * other depth) }
	operator * (other: IntPoint3D) -> This { This new(this width * other x, this height * other y, this depth * other z) }
	operator / (other: This) -> This { This new(this width / other width, this height / other height, this depth / other depth) }
	operator / (other: IntPoint3D) -> This { This new(this width / other x, this height / other y, this depth / other z) }
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
	toFloatSize3D: func -> FloatSize3D { FloatSize3D new(this width as Float, this height as Float, this depth as Float) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this width toString()}, #{this height toString()}, #{this depth toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new (array[0] toInt(), array[1] toInt(), array[2] toInt())
	}
}
operator * (left: Int, right: IntSize3D) -> IntSize3D { IntSize3D new(left * right width, left * right height, left * right depth) }
operator / (left: Int, right: IntSize3D) -> IntSize3D { IntSize3D new(left / right width, left / right height, left / right depth) }
operator * (left: Float, right: IntSize3D) -> IntSize3D { IntSize3D new(left * right width, left * right height, left * right depth) }
operator / (left: Float, right: IntSize3D) -> IntSize3D { IntSize3D new(left / right width, left / right height, left / right depth) }
