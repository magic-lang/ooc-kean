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
import FloatSize2D
import FloatSize3D
import FloatPoint2D
import FloatPoint3D
import FloatTransform2D
import text/StringTokenizer
import structs/ArrayList

// The 3D transform is a 4x4 homogeneous coordinate matrix.
// The element order is:
// A E I M
// B F J N
// C G K O
// D H L P

FloatTransform3D: cover {
	a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p: Float
	operator [] (x, y: Int) -> Float {
		result := 0.0f
		match (x) {
			case 0 =>
				match (y) {
					case 0 => result = this a
					case 1 => result = this b
					case 2 => result = this c
					case 3 => result = this d
					case => OutOfBoundsException new(y, 4) throw()
				}
			case 1 =>
				match (y) {
					case 0 => result = this e
					case 1 => result = this f
					case 2 => result = this g
					case 3 => result = this h
					case => OutOfBoundsException new(y, 4) throw()
				}
			case 2 =>
				match (y) {
					case 0 => result = this i
					case 1 => result = this j
					case 2 => result = this k
					case 3 => result = this l
					case => OutOfBoundsException new(y, 4) throw()
				}
			case 3 =>
				match (y) {
					case 0 => result = this m
					case 1 => result = this n
					case 2 => result = this o
					case 3 => result = this p
					case => OutOfBoundsException new(y, 4) throw()
				}
			case => OutOfBoundsException new(x, 4) throw()
		}
		result
	}
	determinant: Float {
		get {
			this a * this f * this k * this p + this a * this j * this o * this h + this a * this n * this g * this l +
			this e * this b * this o * this l + this e * this j * this c * this p + this e * this n * this k * this d +
			this i * this b * this g * this p + this i * this f * this o * this d + this i * this n * this c * this h +
			this m * this b * this k * this h + this m * this f * this c * this l + this m * this j * this g * this d -
			this a * this f * this o * this l - this a * this j * this g * this p - this a * this n * this k * this h -
			this e * this b * this k * this p - this e * this j * this o * this d - this e * this n * this c * this l -
			this i * this b * this o * this h - this i * this f * this c * this p - this i * this n * this g * this d -
			this m * this b * this g * this l - this m * this f * this k * this d - this m * this j * this c * this h
		}
	}
	translation ::= FloatSize3D new(this m, this n, this o)
	scaling ::= (this scalingX + this scalingY + this scalingZ) / 3.0f
	scalingX ::= (this a squared() + this b squared() + this c squared()) sqrt()
	scalingY ::= (this e squared() + this f squared() + this g squared()) sqrt()
	scalingZ ::= (this i squared() + this j squared() + this k squared()) sqrt()
	inverse: This { get {
		determinant := this determinant
		// If the determinant is 0, the resulting transform will be full of NaN values.
		// No FloatTransform3D instance should have a determinant of 0, so
		// throw an exception, because something has gone wrong, somewhere.
		if (determinant == 0)
			raise("determinant is zero in FloatTransform3D inverse()!")
		a := (this f * this k * this p + this j * this o * this h + this n * this g * this l - this f * this o * this l - this j * this g * this p - this n * this k * this h) / determinant
		e := (this e * this o * this l + this i * this g * this p + this m * this k * this h - this e * this k * this p - this i * this o * this h - this m * this g * this l) / determinant
		i := (this e * this j * this p + this i * this n * this h + this m * this f * this l - this e * this n * this l - this i * this f * this p - this m * this j * this h) / determinant
		m := (this e * this n * this k + this i * this f * this o + this m * this j * this g - this e * this j * this o - this i * this n * this g - this m * this f * this k) / determinant
		b := (this b * this o * this l + this j * this c * this p + this n * this k * this d - this b * this k * this p - this j * this o * this d - this n * this c * this l) / determinant
		f := (this a * this k * this p + this i * this o * this d + this m * this c * this l - this a * this o * this l - this i * this c * this p - this m * this k * this d) / determinant
		j := (this a * this n * this l + this i * this b * this p + this m * this j * this d - this a * this j * this p - this i * this n * this d - this m * this b * this l) / determinant
		n := (this a * this j * this o + this i * this n * this c + this m * this b * this k - this a * this n * this k - this i * this b * this o - this m * this j * this c) / determinant
		c := (this b * this g * this p + this f * this o * this d + this n * this c * this h - this b * this o * this h - this f * this c * this p - this n * this g * this d) / determinant
		g := (this a * this o * this h + this e * this c * this p + this m * this g * this d - this a * this g * this p - this e * this o * this d - this m * this c * this h) / determinant
		k := (this a * this f * this p + this e * this n * this d + this m * this b * this h - this a * this n * this h - this e * this b * this p - this m * this f * this d) / determinant
		o := (this a * this n * this g + this e * this b * this o + this m * this f * this c - this a * this f * this o - this e * this n * this c - this m * this b * this g) / determinant
		d := (this b * this k * this h + this f * this c * this l + this j * this g * this d - this b * this g * this l - this f * this k * this d - this j * this c * this h) / determinant
		h := (this a * this g * this l + this e * this k * this d + this i * this c * this h - this a * this k * this h - this e * this c * this l - this i * this g * this d) / determinant
		l := (this a * this j * this h + this e * this b * this l + this i * this f * this d - this a * this f * this l - this e * this j * this d - this i * this b * this h) / determinant
		p := (this a * this f * this k + this e * this j * this c + this i * this b * this g - this a * this j * this g - this e * this b * this k - this i * this f * this c) / determinant

		This new(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
	}}
	init: func@ (=a, =b, =c, =d, =e, =f, =g, =h, =i, =j, =k, =l, =m, =n, =o, =p)
	init: func@ ~withoutBottomRow (a, b, c, e, f, g, i, j, k, m, n, o: Float) { this init(a, b, c, 0.0f, e, f, g, 0.0f, i, j, k, 0.0f, m, n, o, 1.0f) }
//	init: func@ ~reduced (a, b, d, e, g, h: Float) { this init(a, b, 0.0f, d, e, 0.0f, g, h, 1.0f) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
	init: func@ ~fromFloatTransform2D (transform: FloatTransform2D) {
		this init(transform a, transform b, 0.0f, transform c, transform d, transform e, 0.0f, transform f, 0.0f, 0.0f, 1.0f, 0.0f, transform g, transform h, 0.0f, transform i)
	}
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f) } }
//	setTranslation: func(translation: FloatSize2D) -> This { this translate(translation - this Translation) }
	setScaling: func (scaling: Float) -> This { this scale(scaling / this scaling) }
	setXScaling: func (scaling: Float) -> This { this scale(scaling / this scalingX, 1.0f, 1.0f) }
	setYScaling: func (scaling: Float) -> This { this scale(1.0f, scaling / this scalingY, 1.0f) }
	setZScaling: func (scaling: Float) -> This { this scale(1.0f, 1.0f, scaling / this scalingZ) }
	translate: func (xDelta, yDelta, zDelta: Float) -> This { this createTranslation(xDelta, yDelta, zDelta) * this }
	translate: func ~float (delta: Float) -> This { this translate(delta, delta, delta) }
	translate: func ~point (delta: FloatPoint3D) -> This { this translate(delta x, delta y, delta z) }
	translate: func ~size (delta: FloatSize3D) -> This { this translate(delta width, delta height, delta depth) }
	scale: func (xFactor, yFactor, zFactor: Float) -> This { this createScaling(xFactor, yFactor, zFactor) * this }
	scale: func ~float (factor: Float) -> This { this scale(factor, factor, factor) }
	scale: func ~size (factor: FloatSize3D) -> This { this scale(factor width, factor height, factor depth) }
	rotateX: func (angle: Float) -> This { this createRotationX(angle) * this }
	rotateY: func (angle: Float) -> This { this createRotationY(angle) * this }
	rotateZ: func (angle: Float) -> This { this createRotationZ(angle) * this }
	reflectX: func -> This { this createReflectionX() * this }
	reflectY: func -> This { this createReflectionY() * this }
	reflectZ: func -> This { this createReflectionZ() * this }
	create: static func (a, b, c, d, e, f, g, h, i, j, k, l: Float) -> This { This new(a, b, c, d, e, f, g, h, i, j, k, l) }
	createTranslation: static func (xDelta, yDelta, zDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta, zDelta) }
	createTranslation: static func ~float (delta: Float) -> This { This createTranslation(delta, delta, delta) }
	createTranslation: static func ~size (delta: FloatSize3D) -> This { This createTranslation(delta width, delta height, delta depth) }
	createTranslation: static func ~point (delta: FloatPoint3D) -> This { This createTranslation(delta x, delta y, delta z) }
	createScaling: static func (xFactor, yFactor, zFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, 0.0f, yFactor, 0.0f, 0.0f, 0.0f, zFactor, 0.0f, 0.0f, 0.0f) }
	createScaling: static func ~float (factor: Float) -> This { This createScaling(factor, factor, factor) }
	createScaling: static func ~size (factor: FloatSize3D) -> This { This createScaling(factor width, factor height, factor width) }
	createRotationX: static func (angle: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationY: static func (angle: Float) -> This { This new(angle cos(), 0.0f, (-angle) sin(), 0.0f, 1.0f, 0.0f, angle sin(), 0.0f, angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationZ: static func (angle: Float) -> This { This new(angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createRotation: static func ~pivot (transform: This, pivot: FloatPoint3D) -> This {
		This createTranslation(pivot x, pivot y, pivot z) * transform * This createTranslation(-pivot x, -pivot y, -pivot z)
	}
	createReflectionX: static func -> This { This new(-1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionY: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionZ: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f) }

	operator * (other: This) -> This {
		This new(
			this a * other a + this e * other b + this i * other c + this m * other d,
			this b * other a + this f * other b + this j * other c + this n * other d,
			this c * other a + this g * other b + this k * other c + this o * other d,
			this d * other a + this h * other b + this l * other c + this p * other d,

			this a * other e + this e * other f + this i * other g + this m * other h,
			this b * other e + this f * other f + this j * other g + this n * other h,
			this c * other e + this g * other f + this k * other g + this o * other h,
			this d * other e + this h * other f + this l * other g + this p * other h,

			this a * other i + this e * other j + this i * other k + this m * other l,
			this b * other i + this f * other j + this j * other k + this n * other l,
			this c * other i + this g * other j + this k * other k + this o * other l,
			this d * other i + this h * other j + this l * other k + this p * other l,

			this a * other m + this e * other n + this i * other o + this m * other p,
			this b * other m + this f * other n + this j * other o + this n * other p,
			this c * other m + this g * other n + this k * other o + this o * other p,
			this d * other m + this h * other n + this l * other o + this p * other p
		)
	}
	operator * (other: FloatPoint3D) -> FloatPoint3D {
		FloatPoint3D new(
			this a * other x + this e * other y + this i * other z + this m,
			this b * other x + this f * other y + this j * other z + this n,
			this c * other x + this g * other y + this k * other z + this o
		)
	}
	operator == (other: This) -> Bool {
		this a == other a &&
		this b == other b &&
		this c == other c &&
		this d == other d &&
		this e == other e &&
		this f == other f &&
		this g == other g &&
		this h == other h &&
		this i == other i &&
		this j == other j &&
		this k == other k &&
		this l == other l &&
		this m == other m &&
		this n == other n &&
		this o == other o &&
		this p == other p
	}
	transformProjected: func (point: FloatPoint2D, focalLength: Float) -> FloatPoint2D {
		transformedWorldPoint := this * FloatPoint3D new(point x, point y, focalLength)
		this project(transformedWorldPoint, focalLength)
	}
	project: func (point: FloatPoint3D, focalLength: Float) -> FloatPoint2D {
		projectedPoint := This createProjection(focalLength) * point / point z
		FloatPoint2D new(projectedPoint x, projectedPoint y)
	}
	createProjection: static func (focalLength: Float) -> This {
		This new(focalLength, 0, 0, 0, 0, focalLength, 0, 0, 0, 0, focalLength, 1.0f, 0, 0, 0, 0)
	}
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String {
		"%.8f" formatFloat(this a) >> ", " & "%.8f" formatFloat(this e) >> ", " & "%.8f" formatFloat(this i) >> ", " & "%.8f" formatFloat(this m) >> "\n" & \
		"%.8f" formatFloat(this b) >> ", " & "%.8f" formatFloat(this f) >> ", " & "%.8f" formatFloat(this j) >> ", " & "%.8f" formatFloat(this n) >> "\n" & \
		"%.8f" formatFloat(this c) >> ", " & "%.8f" formatFloat(this g) >> ", " & "%.8f" formatFloat(this k) >> ", " & "%.8f" formatFloat(this o) >> "\n" & \
		"%.8f" formatFloat(this d) >> ", " & "%.8f" formatFloat(this h) >> ", " & "%.8f" formatFloat(this l) >> ", " & "%.8f" formatFloat(this p)
	}
}
