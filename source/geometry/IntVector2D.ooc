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

import IntPoint2D
import FloatVector2D
use base

IntVector2D: cover {
	x, y: Int

	area ::= this x * this y
	hasZeroArea ::= this area == 0
	square ::= this x == this y
	length ::= ((this x squared + this y squared) as Float sqrt())
	absolute ::= This new(this x absolute, this y absolute)

	init: func@ (=x, =y)
	init: func@ ~square (length: Int) { this x = this y = length }
	init: func@ ~default { this init(0, 0) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y }
	swap: func -> This { This new(this y, this x) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	minimum: func ~Int (ceiling: Int) -> This { this minimum(This new(ceiling)) }
	maximum: func ~Int (floor: Int) -> This { this maximum(This new(floor)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	polar: static func (radius, azimuth: Float) -> This { This new((radius * cos(azimuth)) as Int, (radius * sin(azimuth)) as Int) }
	toFloatVector2D: func -> FloatVector2D { FloatVector2D new(this x as Float, this y as Float) }
	toIntPoint2D: func -> IntPoint2D { IntPoint2D new(this x, this y) }
	toString: func -> String { "#{this x toString()}, #{this y toString()}" }
	toText: func -> Text { this x toText() + t", " + this y toText() }

	operator - -> This { This new(-this x, -this y) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y) }
	operator < (other: This) -> Bool { this x < other x && this y < other y }
	operator > (other: This) -> Bool { this x > other x && this y > other y }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y }
	operator == (other: This) -> Bool { this x == other x && this y == other y }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: IntPoint2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: IntPoint2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: IntPoint2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: IntPoint2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Float) -> This { This new(this x * other, this y * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other) }

	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toInt(), parts[1] toInt())
		parts free()
		result
	}

	kean_math_intVector2D_new: unmangled static func (x, y: Int) -> This { This new(x, y) }
}
operator * (left: Int, right: IntVector2D) -> IntVector2D { IntVector2D new(left * right x, left * right y) }
operator / (left: Int, right: IntVector2D) -> IntVector2D { IntVector2D new(left / right x, left / right y) }
operator * (left: Float, right: IntVector2D) -> IntVector2D { IntVector2D new(left * right x, left * right y) }
operator / (left: Float, right: IntVector2D) -> IntVector2D { IntVector2D new(left / right x, left / right y) }
