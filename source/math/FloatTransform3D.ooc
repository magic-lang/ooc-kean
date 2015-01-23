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
import FloatExtension
import FloatSize3D
import FloatPoint3D
import text/StringTokenizer
import structs/ArrayList

// The 2D transform is a 3x3 homogeneous coordinate matrix.
// The element order is:
// A D G J
// B E H K
// C F I L

FloatTransform3D: cover {
	a, b, c, d, e, f, g, h, i, j, k, l: Float
	operator [] (x, y: Int) -> Float {
		result := 0.0f
		match (x) {
			case 0 =>
				match (y) {
					case 0 => result = this a
					case 1 => result = this b
					case 2 => result = this c
					case => OutOfBoundsException new(y, 3) throw()
				}
			case 1 =>
				match (y) {
					case 0 => result = this d
					case 1 => result = this e
					case 2 => result = this f
					case => OutOfBoundsException new(y, 3) throw()
				}
			case 2 =>
				match (y) {
					case 0 => result = this g
					case 1 => result = this h
					case 2 => result = this i
					case => OutOfBoundsException new(y, 3) throw()
				}
			case 3 =>
				match (y) {
					case 0 => result = this j
					case 1 => result = this k
					case 2 => result = this l
					case => OutOfBoundsException new(y, 3) throw()
				}
			case => OutOfBoundsException new(x, 4) throw()
		}
		result
	}
	determinant ::= this a * (this e * this i - this f * this h) + this d * (this h * this c - this i * this b) + this g * (this b * this f - this e * this c)
	translation ::= FloatSize3D new(this j, this k, this l)
	scaling ::= (this scalingX + this scalingY + this scalingZ) / 3.0f
	scalingX ::= (this a squared() + this b squared() + this c squared()) sqrt()
	scalingY ::= (this d squared() + this e squared() + this f squared()) sqrt()
	scalingZ ::= (this g squared() + this h squared() + this i squared()) sqrt()
	rotation ::= this b atan2(this a)
	inverse: This { get {
		determinant := this determinant
		result := This new(
			(this e * this i - this h * this f) / determinant,
			(this h * this c - this b * this i) / determinant,
			(this b * this f - this e * this c) / determinant,
			(this g * this f - this d * this i) / determinant,
			(this a * this i - this g * this c) / determinant,
			(this c * this d - this a * this f) / determinant,
			(this d * this h - this g * this e) / determinant,
			(this g * this b - this a * this h) / determinant,
			(this a * this e - this b * this d) / determinant,
			0.0f,
			0.0f,
			0.0f
		)
		translation := result * This createTranslation(this j, this k, this l)
		result j = -translation j
		result k = -translation k
		result l = -translation l
		result
	}}
	init: func@ (=a, =b, =c, =d, =e, =f, =g, =h, =i, =j, =k, =l)
//	init: func@ ~reduced (a, b, d, e, g, h: Float) { this init(a, b, 0.0f, d, e, 0.0f, g, h, 1.0f) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
//	FIXME: Unary minus
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
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) } }
	create: static func (a, b, c, d, e, f, g, h, i, j, k, l: Float) -> This { This new(a, b, c, d, e, f, g, h, i, j, k, l) }
	createTranslation: static func (xDelta, yDelta, zDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta, zDelta) }
	createTranslation: static func ~float (delta: Float) -> This { This createTranslation(delta, delta, delta) }
	createTranslation: static func ~size (delta: FloatSize3D) -> This { This createTranslation(delta width, delta height, delta depth) }
	createTranslation: static func ~point (delta: FloatPoint3D) -> This { This createTranslation(delta x, delta y, delta z) }
	createScaling: static func (xFactor, yFactor, zFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, 0.0f, yFactor, 0.0f, 0.0f, 0.0f, zFactor, 0.0f, 0.0f, 0.0f) }
	createScaling: static func ~float (factor: Float) -> This { This createScaling(factor, factor, factor) }
	createScaling: static func ~size (factor: FloatSize3D) -> This { This createScaling(factor width, factor height, factor width) }
	createRotationX: static func (angle: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationY: static func (angle: Float) -> This { This new(angle cos(), 0.0f, angle sin(), 0.0f, 1.0f, 0.0f, (-angle) sin(), 0.0f, angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationZ: static func (angle: Float) -> This { This new(angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createRotation: static func ~pivot (transform: This, pivot: FloatPoint3D) -> This {
		This createTranslation(pivot x, pivot y, pivot z) * transform * This createTranslation(-pivot x, -pivot y, -pivot z)
	}
	createReflectionX: static func -> This { This new(-1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionY: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionZ: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f) }
	to4x4: func -> Float* {
		//TODO: Do not use heap array
		array := gc_malloc(Float size * 16) as Float*
		array[0] = this a
		array[1] = this d
		array[2] = this g
		array[3] = this j
		array[4] = this b
		array[5] = this e
		array[6] = this h
		array[7] = this k
		array[8] = this c
		array[9] = this f
		array[10] = this i
		array[11] = this l
		array[12] = array[13] = array[14] = 0
		array[15] = 1
		array
	}
	operator * (other: This) -> This {
		This new(
			this a * other a + this d * other b + this g * other c,
			this b * other a + this e * other b + this h * other c,
			this c * other a + this f * other b + this i * other c,
			this a * other d + this d * other e + this g * other f,
			this b * other d + this e * other e + this h * other f,
			this c * other d + this f * other e + this i * other f,
			this a * other g + this d * other h + this g * other i,
			this b * other g + this e * other h + this h * other i,
			this c * other g + this f * other h + this i * other i,
			this a * other j + this d * other k + this g * other l + this j,
			this b * other j + this e * other k + this h * other l + this k,
			this c * other j + this f * other k + this i * other l + this l
		)
	}
	operator * (other: FloatPoint3D) -> FloatPoint3D {
		FloatPoint3D new(
			this a * other x + this d * other y + this g * other z + this j,
			this b * other x + this e * other y + this h * other z + this k,
			this c * other x + this f * other y + this i * other z + this l
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
		this l == other l
	}
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String {
//		FIXME: How do I concatenate strings, or define them on multple lines?
		"#{this a toString()}, #{this b toString()}, #{this c toString()}, #{this d toString()}, #{this e toString()}, #{this f toString()}, #{this g toString()}, #{this h toString()}, #{this i toString()}, #{this j toString()}, #{this k toString()}, #{this l toString()}"
	}
}
