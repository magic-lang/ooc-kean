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
import IntSize3D
import IntPoint2D
import FloatPoint3D
import structs/ArrayList

IntPoint3D: cover {
	x, y, z: Int
	init: func@ (=x, =y, =z)
	init: func@ ~default { this init(0, 0, 0) }
	init: func@ ~fromPoint2D (point: IntPoint2D, z := 0) { this init(point x, point y, z) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y + this z * other z }
	minimum: func (ceiling: This) -> This { This new(Int minimum~two(this x, ceiling x), Int minimum~two(this y, ceiling y), Int minimum~two(this z, ceiling z)) }
	maximum: func (floor: This) -> This { This new(Int maximum~two(this x, floor x), Int maximum~two(this y, floor y), Int maximum~two(this z, floor z)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator + (other: IntSize3D) -> This { This new(this x + other width, this y + other height, this z + other depth) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator - (other: IntSize3D) -> This { This new(this x - other width, this y - other height, this z - other depth) }
	operator - -> This { This new(-this x, -this y, -this z) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator * (other: IntSize3D) -> This { This new(this x * other width, this y * other height, this z * other depth) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator / (other: IntSize3D) -> This { This new(this x / other width, this y / other height, this z / other depth) }
	operator * (other: Int) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other, this z / other) }
	operator == (other: This) -> Bool { this x == other x && this y == other y && this z == other z }
	operator != (other: This) -> Bool { this x != other x || this y != other y || this z != other z }
	operator < (other: This) -> Bool { this x < other x && this y < other y && this z < other z }
	operator > (other: This) -> Bool { this x > other x && this y > other y && this z > other z }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y && this z <= other z }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y && this z >= other z }
	toFloatPoint3D: func -> FloatPoint3D { FloatPoint3D new(this x as Float, this y as Float, this z as Float) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this x toString()}, #{this y toString()}, #{this z toString()}" }
	parse: static func (input: String) -> This {
		array := input split(',')
		This new(array[0] toInt(), array[1] toInt(), array[2] toInt())
	}
}
operator * (left: Int, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left / right x, left / right y, left / right z) }
operator * (left: Float, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left / right x, left / right y, left / right z) }
