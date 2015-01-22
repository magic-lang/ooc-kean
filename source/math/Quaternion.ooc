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
import FloatPoint3D
import FloatTransform2D
import math
import FloatExtension
Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D

	// q = w + xi + yj + zk
	w ::= this real
	x ::= this imaginary x
	y ::= this imaginary y
	z ::= this imaginary z
	inverse ::= Quaternion new(this w, -this x, -this y, -this z)

	init: func@ (=real, =imaginary)
	init: func@ ~floats (w: Float, x: Float, y: Float, z: Float) { this init(w, FloatPoint3D new(x, y, z)) }
	init: func@ ~default { this init(0, 0, 0, 0) }
	apply: func(vector: FloatPoint3D) -> FloatPoint3D {
 		vectorQuaternion := Quaternion new(0.0f, vector)
		result := hamiltonProduct(hamiltonProduct(this, vectorQuaternion), this inverse)
		FloatPoint3D new(result x, result y, result z)
	}
	hamiltonProduct: static func(left, right: Quaternion) -> Quaternion {
		a1 := left w;
		b1 := left x;
		c1 := left y;
		d1 := left z;
		a2 := right w;
		b2 := right x;
		c2 := right y;
		d2 := right z;

		w := a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
		x := a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
		y := a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2;
		z := a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2;
		return Quaternion new(w, x, y, z);
	}
	getEulerAngles: func() -> FloatPoint3D {
		// http://www.jldoty.com/code/DirectX/YPRfromUF/YPRfromUF.html
		// Should be used in order Yaw -> Pitch -> Roll or Pitch -> Yaw -> Roll,
		// According to jldoty it should be Roll -> Pitch -> Yaw, but this doesn't work
		//
		// Forward, up and right might need to be changed depending on phone coordinate system and camera direction
		// World coordinates: x axis -> west, y axis -> north, z axis -> up
		// Forward is direction of camera.

		forward := FloatPoint3D new(0.0f, 0.0f, -1.0f)
		up := FloatPoint3D new(1.0f, 0.0f, 0.0f)
		right := FloatPoint3D new(0.0f, -1.0f, 0.0f)

		forwardRotated := this apply(forward)
		upRotated := this apply(up)

		pitch := asin(-forwardRotated z) - Float pi / 2.0f
		yaw := atan2(forwardRotated y, forwardRotated x)

		yawTransform := FloatTransform2D new(cos(yaw), sin(yaw), 0.0f, -sin(yaw), cos(yaw), 0.0f, 0.0f, 0.0f, 1.0f)
		pitchTransform := FloatTransform2D new(cos(pitch), 0.0f, -sin(pitch), 0.0f, 1.0f, 0.0f, sin(pitch), 0.0f, cos(pitch))
		yawAndPitch := yawTransform * pitchTransform

		upYawPitch := yawAndPitch * up
		rightYawPitch := yawAndPitch * right

		roll: Float
		if (Float absolute(rightYawPitch x) > Float absolute(rightYawPitch y) && Float absolute(rightYawPitch x) > Float absolute(rightYawPitch z))
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch x - upRotated x) / rightYawPitch x)
		else if (Float absolute(rightYawPitch y) > Float absolute(rightYawPitch z))
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch y - upRotated y) / rightYawPitch y)
		else
			roll = asin((upYawPitch scalarProduct(upRotated) * upYawPitch z - upRotated z) / rightYawPitch z)

		FloatPoint3D new(pitch, -yaw, roll)
	}
	getTransform: static func(eulerAngles: FloatPoint3D, k: Float) -> FloatTransform2D {
			rx := FloatTransform2D createXRotation(eulerAngles x, k)
			ry := FloatTransform2D createYRotation(eulerAngles y, k)
			rz := FloatTransform2D createZRotation(eulerAngles z)
			/*return ry * rx * rz // Roll -> Pitch -> Yaw*/
			/*return rx * ry * rz // Roll -> Yaw -> Pitch*/
			/*return rz * ry * rx // Pitch -> Yaw -> Roll*/
			return rz * rx * ry // Yaw -> Pitch -> Roll // Currently used
	}
	toString: func -> String { "Real:" + this real toString() + " Imaginary: " + this imaginary toString() }
}
