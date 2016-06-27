/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
	toString: func (decimals := 6) -> String { this _quaternion toString(decimals) }

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
}

extend Cell<FloatRotation3D> {
	toString: func ~floatrotation3d -> String { (this val as FloatRotation3D) toString() }
}
