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
import FloatPoint3D
import FloatTransform2D
import FloatTransform3D
import Quaternion

FloatRotation3D: cover {
	_quaternion: Quaternion
	identity: static This { get { This new(Quaternion identity) } }
	inverse ::= This new(this _quaternion inverse)
	normalized ::= This new(this _quaternion normalized)
	x := 0.0f
	y := 0.0f
	z := 0.0f
	init: func@ ~full(=x, =y, =z) { }
	init: func@ ~fromPoint(point: FloatPoint3D) { this init(point x, point y, point z) }
	init: func@ ~default { this init(Quaternion new(0.0f, 0.0f, 0.0f, 0.0f)) }
	init: func@ ~fromQuaternion (=_quaternion)

	clamp: func ~point(floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	clamp: func ~float(floor, ceiling: Float) -> This { This new(this x clamp(floor, ceiling), this y clamp(floor, ceiling), this z clamp(floor, ceiling)) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator - -> This { This new(-this x, -this y, -this z) }
	operator * (other: This) -> This { This new(this _quaternion * other _quaternion) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator == (other: This) -> Bool { this _quaternion == other _quaternion }
	operator != (other: This) -> Bool { this _quaternion != other _quaternion }
	operator < (other: This) -> Bool { this _quaternion < other _quaternion }
	operator > (other: This) -> Bool { this _quaternion > other _quaternion }
	operator <= (other: This) -> Bool { this _quaternion <= other _quaternion }
	operator >= (other: This) -> Bool { this _quaternion >= other _quaternion }
	toString: func -> String { this _quaternion toString() }
	sphericalLinearInterpolation: func (other: This, factor: Float) -> This {
		This new(this _quaternion sphericalLinearInterpolation(other _quaternion, factor))
	}
	toFloatTransform3D: func -> FloatTransform3D {
		this _quaternion toFloatTransform3D()
	}
	dotProduct: func(other: This) -> Float {
		this _quaternion dotProduct(other _quaternion)
	}
	angle: func(other: This) -> Float {
		result := acos(Float absolute(this dotProduct(other))) as Float
		result = result == result ? result : 0.0f
	}
	kean_math_floatRotation3D_new: unmangled static func ~API (quaternion: Quaternion) -> This { This new(quaternion) }
}
operator * (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left / right x, left / right y, left / right z) }
operator - (left: Float, right: FloatRotation3D) -> FloatRotation3D { FloatRotation3D new(left - right x, left - right y, left - right z) }
