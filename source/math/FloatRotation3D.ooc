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
import Quaternion

FloatRotation3D: cover {
	_quaternion: Quaternion
	identity: static This { get { This new(Quaternion identity) } }
	inverse ::= This new(this _quaternion inverse)
	normalized ::= This new(this _quaternion normalized)
	transform ::= this _quaternion transform

	init: func@ ~default { this init(Quaternion new(0.0f, 0.0f, 0.0f, 0.0f)) }
	init: func@ ~fromQuaternion (=_quaternion)

	operator * (other: This) -> This { This new(this _quaternion * other _quaternion) }
	operator == (other: This) -> Bool { this _quaternion == other _quaternion }
	operator != (other: This) -> Bool { this _quaternion != other _quaternion }
	createRotationZ: static func (angle: Float) -> This { This new(Quaternion createRotationZ(angle)) }
	sphericalLinearInterpolation: func (other: This, factor: Float) -> This {
		This new(this _quaternion sphericalLinearInterpolation(other _quaternion, factor))
	}
	angle: func (other: This) -> Float {
		result := acos(Float absolute(this _quaternion dotProduct(other _quaternion))) as Float
		result = result == result ? result : 0.0f
	}
	toString: func -> String { this _quaternion toString() }
	kean_math_floatRotation3D_new: unmangled static func (quaternion: Quaternion) -> This { This new(quaternion) }
}
