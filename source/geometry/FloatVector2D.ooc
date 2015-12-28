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
import FloatPoint2D
import IntVector2D
use ooc-base

FloatVector2D: cover {
	x, y: Float

	area ::= this x * this y
	length ::= this norm
	hasZeroArea ::= this area equals(0.0f)
	norm ::= (this x squared + this y squared) sqrt()
	azimuth ::= this y atan2(this x)
	absolute ::= This new(this x absolute, this y absolute)

	init: func@ (=x, =y)
	init: func@ ~square (length: Float) { this x = this y = length }
	init: func@ ~default { this init(0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this x abs() pow(p) + this y abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y }
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1.0f, 1.0f) acos() * (this x * other y - this y * other x < 0.0f ? -1.0f : 1.0f)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	swap: func -> This { This new(this y, this x) }
	round: func -> This { This new(this x round(), this y round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil()) }
	floor: func -> This { This new(this x floor(), this y floor()) }
	minimum: func (ceiling: This) -> This { This new(Float minimum(this x, ceiling x), Float minimum(this y, ceiling y)) }
	maximum: func (floor: This) -> This { This new(Float maximum(this x, floor x), Float maximum(this y, floor y)) }
	minimum: func ~Float (ceiling: Float) -> This { this minimum(This new(ceiling)) }
	maximum: func ~Float (floor: Float) -> This { this maximum(This new(floor)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	toIntVector2D: func -> IntVector2D { IntVector2D new(this x as Int, this y as Int) }
	toFloatPoint2D: func -> FloatPoint2D { FloatPoint2D new(this x, this y) }
	toString: func -> String { "#{this x toString()}, #{this y toString()}" }

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
	operator + (other: FloatPoint2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: FloatPoint2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: FloatPoint2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: FloatPoint2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Float) -> This { This new(this x * other, this y * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other) }
	operator as -> String { this toString() }

	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }

	polar: static func (radius, azimuth: Float) -> This { This new(radius * cos(azimuth), radius * sin(azimuth)) }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toFloat(), parts[1] toFloat())
		parts free()
		result
	}
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(Float linearInterpolation(a x, b x, ratio), Float linearInterpolation(a y, b y, ratio))
	}
}
operator * (left: Float, right: FloatVector2D) -> FloatVector2D { FloatVector2D new(left * right x, left * right y) }
operator / (left: Float, right: FloatVector2D) -> FloatVector2D { FloatVector2D new(left / right x, left / right y) }
operator * (left: Int, right: FloatVector2D) -> FloatVector2D { FloatVector2D new(left * right x, left * right y) }
operator / (left: Int, right: FloatVector2D) -> FloatVector2D { FloatVector2D new(left / right x, left / right y) }
