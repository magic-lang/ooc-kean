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
import FloatVector2D
import IntPoint2D
use ooc-base

FloatPoint2D: cover {
	x, y: Float

	norm ::= (this x * this x + this y * this y) sqrt()
	azimuth ::= this y atan2(this x)

	init: func@ (=x, =y)
	init: func@ ~default { this init(0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this x abs() pow(p) + this y abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y }
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1, 1) acos() * (this x * other y - this y * other x < 0 ? -1 : 1)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	distanceSquared: func (other: This) -> Float {
		distanceVector := this - other
		distanceVector x * distanceVector x + distanceVector y * distanceVector y
	}
	swap: func -> This { This new(this y, this x) }
	round: func -> This { This new(this x round(), this y round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil()) }
	floor: func -> This { This new(this x floor(), this y floor()) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	polar: static func (radius, azimuth: Float) -> This { This new(radius * cos(azimuth), radius * sin(azimuth)) }
	toIntPoint2D: func -> IntPoint2D { IntPoint2D new(this x as Int, this y as Int) }
	toFloatVector2D: func -> FloatVector2D { FloatVector2D new(this x, this y) }
	toString: func -> String { this x toString() & ", " clone() & this y toString() }
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
	operator != (other: This) -> Bool { this x != other x || this y != other y }
	operator + (other: FloatVector2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: FloatVector2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: FloatVector2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: FloatVector2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Float) -> This { This new(this x * other, this y * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other) }

	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toFloat(), parts[1] toFloat())
		parts free()
		result
	}
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(ratio linearInterpolation(a x, b x), ratio linearInterpolation(a y, b y))
	}
}
operator * (left: Float, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left * right x, left * right y) }
operator / (left: Float, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left / right x, left / right y) }
operator * (left: Int, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left * right x, left * right y) }
operator / (left: Int, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left / right x, left / right y) }
