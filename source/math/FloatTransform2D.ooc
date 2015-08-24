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
import FloatPoint2D
import FloatBox2D
import IntTransform2D
import text/StringTokenizer
import structs/ArrayList
import FloatEuclidTransform, FloatTransform3D, FloatPoint3D

// The 2D transform is a 3x3 homogeneous coordinate matrix.
// The element order is:
// A D G
// B E H
// C F I

FloatTransform2D: cover {
	a, b, c, d, e, f, g, h, i: Float
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
			case => OutOfBoundsException new(x, 3) throw()
		}
		result
	}
	determinant ::= this a * this e * this i + this d * this h * this c + this g * this b * this f - this g * this e * this c - this d * this b * this i - this a * this h * this f

	translation ::= FloatSize2D new(this g, this h)
	scaling ::= (this scalingX + this scalingY) / 2.0f
	scalingX ::= (this a * this a + this b * this b) sqrt()
	scalingY ::= (this d * this d + this e * this e) sqrt()
	rotation ::= this b atan2(this a)
	inverse: This { get {
		determinant := this determinant
		This new(
			(this e * this i - this h * this f) / determinant,
			(this h * this c - this b * this i) / determinant,
			(this b * this f - this e * this c) / determinant,
			(this g * this f - this d * this i) / determinant,
			(this a * this i - this g * this c) / determinant,
			(this c * this d - this a * this f) / determinant,
			(this d * this h - this g * this e) / determinant,
			(this g * this b - this a * this h) / determinant,
			(this a * this e - this b * this d) / determinant
		)
	}}
	isProjective ::= this determinant != 0.0f
	isAffine ::= this c == 0.0f && this f == 0.0f && this i == 1.0f
	isSimilarity ::= this == This create(this translation, this scaling, this rotation)
	isEuclidian ::= this == This create(this translation, this rotation)
	isIdentity ::= (this a == 1.0f && this e == 1.0f && this i == 1.0f) && (this b == 0.0f && this c == 0.0f && this d == 0.0f && this f == 0.0f && this g == 0.0f && this h == 0.0f)
	init: func@ (=a, =b, =c, =d, =e, =f, =g, =h, =i)
	init: func@ ~reduced (a, b, d, e, g, h: Float) { this init(a, b, 0.0f, d, e, 0.0f, g, h, 1.0f) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
	setTranslation: func (translation: FloatSize2D) -> This { this translate(translation - this translation) }
	setScaling: func (scaling: Float) -> This { this scale(scaling / this scaling) }
	setXScaling: func (scaling: Float) -> This { this scale(scaling / this scalingX, 1.0f) }
	setYScaling: func (scaling: Float) -> This { this scale(1.0f, scaling / this scalingY) }
	setRotation: func (rotation: Float) -> This { this rotate(rotation - this rotation) }
	translate: func (xDelta, yDelta: Float) -> This { this createTranslation(xDelta, yDelta) * this }
	translate: func ~float (delta: Float) -> This { this translate(delta, delta) }
	translate: func ~point (delta: FloatPoint2D) -> This { this translate(delta x, delta y) }
	translate: func ~size (delta: FloatSize2D) -> This { this translate(delta width, delta height) }
	scale: func (xFactor, yFactor: Float) -> This { this createScaling(xFactor, yFactor) * this }
	scale: func ~float (factor: Float) -> This { this scale(factor, factor) }
	scale: func ~size (factor: FloatSize2D) -> This { this scale(factor width, factor height) }
	rotate: func (angle: Float) -> This { this createZRotation(angle) * this }
	skewX: func (angle: Float) -> This { this createSkewingX(angle) * this }
	skewY: func (angle: Float) -> This { this createSkewingY(angle) * this }
	reflectX: func -> This { this createReflectionX() * this }
	reflectY: func -> This { this createReflectionY() * this }
	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) } }
	toIntTransform2D: func -> IntTransform2D { IntTransform2D new(this a, this b, this c, this d, this e, this f, this g, this h, this i) }
	create: static func (translation: FloatSize2D, scale, rotation: Float) -> This {
		This new(rotation cos() * scale, rotation sin() * scale, -rotation sin() * scale, rotation cos() * scale, translation width, translation height)
	}
	create: static func ~reduced (translation: FloatSize2D, rotation: Float) -> This { This create(translation, 1.0f, rotation) }
	createTranslation: static func (xDelta, yDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta) }
	createTranslation: static func ~float (delta: Float) -> This { This createTranslation(delta, delta) }
	createTranslation: static func ~size (delta: FloatSize2D) -> This { This createTranslation(delta width, delta height) }
	createTranslation: static func ~point (delta: FloatPoint2D) -> This { This createTranslation(delta x, delta y) }
	createScaling: static func (xFactor, yFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, yFactor, 0.0f, 0.0f) }
	createScaling: static func ~float (factor: Float) -> This { This createScaling(factor, factor) }
	createScaling: static func ~size (factor: FloatSize2D) -> This { This createScaling(factor width, factor height) }
	createZRotation: static func (angle: Float) -> This { This new(angle cos(), angle sin(), -angle sin(), angle cos(), 0.0f, 0.0f) }
	createXRotation: static func (angle, k: Float) -> This { This new(1 / cos(angle), 0.0f, 0.0f, 0.0f, 1, tan(angle) * k, 0.0f, -tan(angle) / k, 1) }
	createYRotation: static func (angle, k: Float) -> This { This new(1, 0.0f, tan(angle) * k, 0.0f, 1 / cos(angle), 0.0f, -tan(angle) / k, 0.0f, 1) }
	createZRotation: static func ~pivot (angle: Float, pivot: FloatPoint2D) -> This {
		one := 1.0f
		sine := angle sin()
		cosine := angle cos()
		This new(cosine, sine, -sine, cosine, (one - cosine) * pivot x + sine * pivot y, -sine * pivot x + (one - cosine) * pivot y)
	}
	createSkewingX: static func (angle: Float) -> This { This new(1.0f, 0.0f, angle sin(), 1.0f, 0.0f, 0.0f) }
	createSkewingY: static func (angle: Float) -> This { This new(1.0f, angle sin(), 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionX: static func -> This { This new(-1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionY: static func -> This { This new(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f) }
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
			this c * other g + this f * other h + this i * other i
		)
	}
	operator * (other: FloatPoint2D) -> FloatPoint2D {
		divisor := this c * other x + this f * other y + this i
		FloatPoint2D new((this a * other x + this d * other y + this g) / divisor, (this b * other x + this e * other y + this h) / divisor)
	}
	operator * (other: FloatPoint3D) -> FloatPoint3D {
		FloatPoint3D new(this a * other x + this d * other y + this g * other z, this b * other x + this e * other y + this h * other z, this c * other x + this f * other y + this i * other z)
	}
	operator * (other: FloatBox2D) -> FloatBox2D {
		FloatBox2D new(this * other leftTop, this * other rightBottom)
	}
	operator / (value: Float) -> This {
		This new(
			this a / value,
			this b / value,
			this c / value,
			this d / value,
			this e / value,
			this f / value,
			this g / value,
			this h / value,
			this i / value
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
		this i == other i
	}
	to3DTransformArray: func -> Float* {
		array := gc_malloc(Float size * 16) as Float*
		this to3DTransformArray(array)
		array
	}
	to3DTransformArray: func ~proc (array: Float*) {
		array[0] = this a
		array[1] = this b
		array[2] = 0.0f
		array[3] = this c
		array[4] = this d
		array[5] = this e
		array[6] = 0.0f
		array[7] = this f
		array[8] = 0.0f
		array[9] = 0.0f
		array[10] = 1.0f
		array[11] = 0.0f
		array[12] = this g
		array[13] = this h
		array[14] = 0.0f
		array[15] = this i
	}
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String {
		"%8f" formatFloat(this a) >> ", " & "%8f" formatFloat(this b) >> ", " & "%8f" formatFloat(this c) >> "\t" & \
		"%8f" formatFloat(this d) >> ", " & "%8f" formatFloat(this e) >> ", " & "%8f" formatFloat(this f) >> "\t" & \
		"%8f" formatFloat(this g) >> ", " & "%8f" formatFloat(this h) >> ", " & "%8f" formatFloat(this i) >> "\t"
	}
}
