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
import FloatRotation3D
import FloatTransform2D
import math

Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D

	// q = w + xi + yj + zk
	w ::= this real
	x ::= this imaginary x
	y ::= this imaginary y
	z ::= this imaginary z
	inverse ::= Quaternion new(this w, -this x, -this y, -this z)

	isValid ::= (this w == this w && this x == this x && this y == this y && this z == this z)
	isIdentity ::= (this w == 1.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	isNull ::= (this w == 0.0f && this x == 0.0f && this y == 0.0f && this z == 0.0f)
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f) } }
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
	getEulerAngles: func() -> FloatRotation3D {
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

		FloatRotation3D new(pitch, -yaw, roll)
	}
	norm: func -> Float {
		(this real * this real + this imaginary norm * this imaginary norm) sqrt()
	}
	logarithm: func -> Quaternion {
		result: Quaternion
		norm := this norm()
		point3DNorm := this imaginary norm
		if (point3DNorm != 0)
			result = Quaternion new(norm log(), (this imaginary / point3DNorm) * (this real / norm) acos())
		else
			result = Quaternion new(norm, 0.0f, 0.0f, 0.0f)
		result
	}
	exponential: func -> Quaternion {
		result: Quaternion
		point3DNorm := this imaginary norm
		exponentialReal := this real exp()
		if (point3DNorm != 0)
			result = Quaternion new(exponentialReal * point3DNorm cos(), exponentialReal * (this imaginary / point3DNorm) * point3DNorm sin())
		else
			result = Quaternion new(exponentialReal, 0.0f, 0.0f, 0.0f)
		result
	}
	operator == (other: This) -> Bool {
		this w ==  w &&
		this x ==  x &&
		this y ==  y &&
		this z == other z
	}
	operator + (other: This) -> This {
		This new(this w + other w, this x + other x, this y + other y, this z + other z)
	}
	operator - (other: This) -> This {
		This new(this w - other w, this x - other x, this y - other y, this z - other z)
	}
	operator - -> This {
		This new(-this real, -this imaginary)
	}
	operator / (value: Float) -> This {
		This new(this w / value, this x / value, this y / value, this z / value)
	}
	operator * (value: Float) -> This {
		This new(this w * value, this x * value, this y * value, this z * value)
	}
	operator * (other: This) -> This {
		realResult := this real * other real - this imaginary scalarProduct(other imaginary)
		imaginaryResult := this real * other imaginary + this imaginary * other real + this imaginary vectorProduct(other imaginary)
		This new(realResult, imaginaryResult)
	}
	toString: func -> String { "Real:" + "%8f" format(this real) + " Imaginary: " + "%8f" format(this imaginary x) + " " + "%8f" format(this imaginary y) + " " + "%8f" format(this imaginary z)}
}
operator * (value: Float, other: Quaternion) -> Quaternion {
	other * value
}
