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
import math
import FloatExtension
Quaternion: cover {
	real: Float
	imaginary: FloatPoint3D
	// en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
	// q = w + xi + yj + zk
	w ::= this real // q0
	x ::= this imaginary x // i, q1
	y ::= this imaginary y // j, q2
	z ::= this imaginary z // k, q3
	inverse ::= Quaternion new(this w, -this x, -this y, -this z)

	init: func@ (=real, =imaginary)
	init: func@ ~floats (w: Float, x: Float, y: Float, z: Float) { this init(w, FloatPoint3D new(x, y, z)) }
	init: func@ ~default { this init(0, 0, 0, 0) }
	apply: func(vector: FloatPoint3D) -> FloatPoint3D {
 		vectorQuaternion := Quaternion new(0.0f, vector)
		result := hamiltonProduct(hamiltonProduct(this, vectorQuaternion), this inverse)
		FloatPoint3D new(result y, result z, result w)
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

		x := a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
		y := a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
		z := a1 * c2 - b1 * d2 + c1 * a2 + d1 * b2;
		w := a1 * d2 + b1 * c2 - c1 * b2 + d1 * a2;
		return Quaternion new(w, x, y, z);
	}
	toString: func -> String { "Real:" + this real toString() + " Imaginary: " + this imaginary toString() }
	/*
	vector4 hamiltonProduct(vector4 v1, vector4 v2) {
	vector4 result;
	float a1 = v1.x;
	float b1 = v1.y;
	float c1 = v1.z;
	float d1 = v1.w;
	float a2 = v2.x;
	float b2 = v2.y;
	float c2 = v2.z;
	float d2 = v2.w;

	result.x = a1*a2 - b1*b2 - c1*c2 - d1*d2;
	result.y = a1*b2 + b1*a2 + c1*d2 - d1*c2;
	result.z = a1*c2 - b1*d2 + c1*a2 + d1*b2;
	result.w = a1*d2 + b1*c2 - c1*b2 + d1*a2;
	return result;
}
vector3 quaternionMult(vector4 quaternion, vector3 vec) {
vector3 result;
vector4 R = quaternion;
vector4 P; P.x = 0; P.y = vec.x; P.z = vec.y; P.w = vec.z;
vector4 Rn; Rn.x = R.x; Rn.y = -R.y; Rn.z = -R.z; Rn.w = -R.w;
vector4 Hrp = hamiltonProduct(R, P);
vector4 Hrpn = hamiltonProduct(Hrp, Rn);
result.x = Hrpn.y; result.y = Hrpn.z; result.z = Hrpn.w;
return result;
}
*/
}
