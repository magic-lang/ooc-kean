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

use base
import IntVector2D
import IntPoint2D
import FloatTransform2D

// The 2D transform is a 3x3 homogeneous coordinate matrix.
// The element order is:
// A D G
// B E H
// C F I

IntTransform2D: cover {
	a, b, c, d, e, f, g, h, i: Int

	determinant ::= this a * this e * this i + this d * this h * this c + this g * this b * this f - this g * this e * this c - this d * this b * this i - this a * this h * this f
	translation ::= IntVector2D new(this g, this h)
	isProjective ::= this determinant != 0
	isAffine ::= this c == 0 && this f == 0 && this i == 1
	isIdentity ::= (this a == 1 && this e == 1 && this i == 1) && (this b == 0 && this c == 0 && this d == 0 && this f == 0 && this g == 0 && this h == 0)
	inverse: This { get {
		determinant := this determinant
		if (determinant == 0)
			raise("Determinant is zero in FloatTransform2D inverse()")
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

	init: func@ (=a, =b, =c, =d, =e, =f, =g, =h, =i)
	init: func@ ~reduced (a, b, d, e, g, h: Float) { this init(a, b, 0, d, e, 0, g, h, 1) }
	init: func@ ~default { this init(0, 0, 0, 0, 0, 0, 0, 0, 0) }
	setTranslation: func (translation: IntVector2D) -> This { this translate(translation - this translation) }
	translate: func (xDelta, yDelta: Int) -> This { this createTranslation(xDelta, yDelta) * this }
	translate: func ~float (delta: Int) -> This { this translate(delta, delta) }
	translate: func ~point (delta: IntPoint2D) -> This { this translate(delta x, delta y) }
	translate: func ~size (delta: IntVector2D) -> This { this translate(delta x, delta y) }
	scale: func (xFactor, yFactor: Int) -> This { this createScaling(xFactor, yFactor) * this }
	scale: func ~float (factor: Int) -> This { this scale(factor, factor) }
	scale: func ~size (factor: IntVector2D) -> This { this scale(factor x, factor y) }
	rotate: func (angle: Float) -> This { this createZRotation(angle) * this }
	skewX: func (angle: Float) -> This { this createSkewingX(angle) * this }
	skewY: func (angle: Float) -> This { this createSkewingY(angle) * this }
	reflectX: func -> This { this createReflectionX() * this }
	reflectY: func -> This { this createReflectionY() * this }
	toString: func -> String {
		"#{this a toString()}, #{this b toString()}, #{this c toString()}, \
		#{this d toString()}, #{this e toString()}, #{this f toString()}, \
		#{this g toString()}, #{this h toString()}, #{this i toString()}"
	}
	toText: func -> Text {
		result: Text
		textBuilder := TextBuilder new()
		textBuilder append(this a toText() + t", " + this b toText() + t", " + this c toText())
		textBuilder append(this d toText() + t", " + this e toText() + t", " + this f toText())
		textBuilder append(this g toText() + t", " + this h toText() + t", " + this i toText())
		result = textBuilder join(t"\t")
		textBuilder free()
		result
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
			this c * other g + this f * other h + this i * other i
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
	operator != (other: This) -> Bool {
		!(this == other)
	}
	operator [] (x, y: Int) -> Int {
		version (safe) {
			if (x < 0 || x > 2 || y < 0 || y > 2)
				raise("Out of bounds in IntTransform2D get operator (#{x}, #{y})")
		}
		result := 0
		match (x) {
			case 0 =>
				match (y) {
					case 0 => result = this a
					case 1 => result = this b
					case 2 => result = this c
				}
			case 1 =>
				match (y) {
					case 0 => result = this d
					case 1 => result = this e
					case 2 => result = this f
				}
			case 2 =>
				match (y) {
					case 0 => result = this g
					case 1 => result = this h
					case 2 => result = this i
				}
		}
		result
	}
	operator * (other: IntPoint2D) -> IntPoint2D {
		divisor := this c * other x + this f * other y + this i
		IntPoint2D new((this a * other x + this d * other y + this g) / divisor, (this b * other x + this e * other y + this h) / divisor)
	}

	identity: static This { get { This new(1, 0, 0, 1, 0, 0) } }

	toFloatTransform2D: func -> FloatTransform2D { FloatTransform2D new(this a, this b, this c, this d, this e, this f, this g, this h, this i) }
	create: static func (translation: IntVector2D, scale, rotation: Float) -> This {
		This new(rotation cos() * scale, rotation sin() * scale, -rotation sin() * scale, rotation cos() * scale, translation x, translation y)
	}
	create: static func ~reduced (translation: IntVector2D, rotation: Float) -> This { This create(translation, 1, rotation) }
	createTranslation: static func (xDelta, yDelta: Int) -> This { This new(1, 0, 0, 1, xDelta, yDelta) }
	createTranslation: static func ~float (delta: Int) -> This { This createTranslation(delta, delta) }
	createTranslation: static func ~size (delta: IntVector2D) -> This { This createTranslation(delta x, delta y) }
	createTranslation: static func ~point (delta: IntPoint2D) -> This { This createTranslation(delta x, delta y) }
	createScaling: static func (xFactor, yFactor: Int) -> This { This new(xFactor, 0, 0, yFactor, 0, 0) }
	createScaling: static func ~float (factor: Int) -> This { This createScaling(factor, factor) }
	createScaling: static func ~size (factor: IntVector2D) -> This { This createScaling(factor x, factor y) }
	createZRotation: static func (angle: Float) -> This { This new(angle cos(), angle sin(), -angle sin(), angle cos(), 0, 0) }
	createZRotation: static func ~pivot (angle: Float, pivot: IntPoint2D) -> This {
		one := 1
		sine := angle sin()
		cosine := angle cos()
		This new(cosine, sine, -sine, cosine, (one - cosine) * pivot x + sine * pivot y, -sine * pivot x + (one - cosine) * pivot y)
	}
	createSkewingX: static func (angle: Float) -> This { This new(1, 0, angle sin(), 1, 0, 0) }
	createSkewingY: static func (angle: Float) -> This { This new(1, angle sin(), 0, 1, 0, 0) }
	createReflectionX: static func -> This { This new(-1, 0, 0, 1, 0, 0) }
	createReflectionY: static func -> This { This new(1, 0, 0, -1, 0, 0) }
}
