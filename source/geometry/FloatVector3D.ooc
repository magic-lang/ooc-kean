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
use ooc-math
import FloatPoint3D
import IntPoint3D
import IntVector3D
use ooc-base

FloatVector3D: cover {
	x, y, z: Float
	volume ::= this x * this y * this z
	length ::= this norm
	empty ::= this x equals(0.0f) || this y equals(0.0f) || this z equals(0.0f)
	norm ::= (this x squared() + this y squared() + this z squared()) sqrt()
	azimuth ::= this y atan2(this x)
	isValid ::= (this x == this x && this y == this y && this z == this z)
	basisX: static This { get { This new(1, 0, 0) } }
	basisY: static This { get { This new(0, 1, 0) } }
	basisZ: static This { get { This new(0, 0, 1) } }
	init: func@ (=x, =y, =z)
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this x abs() pow(p) + this y abs() pow(p) + this z abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y + this z * other z }
	vectorProduct: func (other: This) -> This {
		This new(
			this y * other z - other y * this z,
			-(this x * other z - other x * this z),
			this x * other y - other x * this y
		)
	}
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1.0f, 1.0f) acos() * (this x * other y - this y * other x < 0.0f ? -1.0f : 1.0f)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	round: func -> This { This new(this x round(), this y round(), this z round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil(), this z ceil()) }
	floor: func -> This { This new(this x floor(), this y floor(), this z floor()) }
	minimum: func (ceiling: This) -> This { This new(Float minimum(this x, ceiling x), Float minimum(this y, ceiling y), Float minimum(this z, ceiling z)) }
	maximum: func (floor: This) -> This { This new(Float maximum(this x, floor x), Float maximum(this y, floor y), Float maximum(this z, floor z)) }
	clamp: func (floor, ceiling: This) -> This {
		This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z))
	}
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator - -> This { This new(-this x, -this y, -this z) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other, this z / other) }
	operator == (other: This) -> Bool { this x == other x && this y == other y && this z == other z }
	operator != (other: This) -> Bool { !(this == other) }
	operator < (other: This) -> Bool { this x < other x && this y < other y && this z < other z }
	operator > (other: This) -> Bool { this x > other x && this y > other y && this z > other z }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y && this z <= other z }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y && this z >= other z }
	toIntVector3D: func -> IntVector3D { IntVector3D new(this x as Int, this y as Int, this z as Int) }
	toFloatPoint3D: func -> FloatPoint3D { FloatPoint3D new(this x, this y, this z) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this x toString()}, #{this y toString()}, #{this z toString()}" }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toFloat(), parts[1] toFloat(), parts[2] toFloat())
		parts free()
		result
	}
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(Float linearInterpolation(a x, b x, ratio), Float linearInterpolation(a y, b y, ratio), Float linearInterpolation(a z, b z, ratio))
	}
}
operator * (left: Float, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left / right x, left / right y, left / right z) }
operator * (left: Int, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left / right x, left / right y, left / right z) }
