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

use math
import Quaternion

FloatRotation3D: cover {
	_quaternion: Quaternion

	inverse ::= This new(this _quaternion inverse)
	normalized ::= This new(this _quaternion normalized)
	transform ::= this _quaternion transform
	x ::= this _quaternion rotationX
	y ::= this _quaternion rotationY
	z ::= this _quaternion rotationZ

	init: func@ ~default { this init(Quaternion new(0.0f, 0.0f, 0.0f, 0.0f)) }
	init: func@ ~fromQuaternion (=_quaternion)
	sphericalLinearInterpolation: func (other: This, factor: Float) -> This {
		This new(this _quaternion sphericalLinearInterpolation(other _quaternion, factor))
	}
	angle: func (other: This) -> Float { this _quaternion angle(other _quaternion) }
	toString: func -> String { this _quaternion toString() }
	toText: func -> Text { this _quaternion toText() }

	operator * (other: This) -> This { This new(this _quaternion * other _quaternion) }
	operator == (other: This) -> Bool { this _quaternion == other _quaternion }
	operator != (other: This) -> Bool { this _quaternion != other _quaternion }

	identity: static This { get { This new(Quaternion identity) } }

	createRotationX: static func (angle: Float) -> This { This new(Quaternion createRotationX(angle)) }
	createRotationY: static func (angle: Float) -> This { This new(Quaternion createRotationY(angle)) }
	createRotationZ: static func (angle: Float) -> This { This new(Quaternion createRotationZ(angle)) }
	createFromEulerAngles: static func (rotationX, rotationY, rotationZ: Float) -> This {
		This new(Quaternion createFromEulerAngles(rotationX, rotationY, rotationZ))
	}

	kean_math_floatRotation3D_new: unmangled static func (quaternion: Quaternion) -> This { This new(quaternion) }
}
