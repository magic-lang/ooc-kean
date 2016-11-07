/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use math
import IntVector2D
import FloatVector2D
import FloatPoint2D
import FloatBox2D
import FloatEuclidTransform, FloatTransform3D, FloatPoint3D

// The 2D transform is a 3x3 homogeneous coordinate matrix.
// The element order is:
// A D G
// B E H
// C F I

FloatTransform2D: cover {
	a, b, c, d, e, f, g, h, i: Float

	determinant ::= this a * this e * this i + this d * this h * this c + this g * this b * this f - this g * this e * this c - this d * this b * this i - this a * this h * this f
	translation ::= FloatVector2D new(this g, this h)
	scaling ::= (this scalingX + this scalingY) / 2.0f
	scalingX ::= (this a * this a + this b * this b) sqrt()
	scalingY ::= (this d * this d + this e * this e) sqrt()
	rotationZ ::= this b atan2(this a)
	isProjective ::= !this determinant equals(0.0f)
	isAffine ::= this c equals(0.0f) && this f equals(0.0f) && this i equals(1.0f)
	isSimilarity ::= this == This create(this translation, this scaling, this rotationZ)
	isEuclidian ::= this == This create(this translation, this rotationZ)
	isIdentity ::= this a equals(1.0f) && this e equals(1.0f) && this i equals(1.0f) && this b equals(0.0f) && this c equals(0.0f) && this d equals(0.0f) && this f equals(0.0f) && this g equals(0.0f) && this h equals(0.0f)
	inverse: This { get {
		determinant := this determinant
		Debug error(determinant equals(0.0f), "Determinant is zero in FloatTransform2D inverse()")
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
	init: func@ ~reduced (a, b, d, e, g, h: Float) { this init(a, b, 0.0f, d, e, 0.0f, g, h, 1.0f) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
	setTranslation: func (translation: FloatVector2D) -> This { this translate(translation - this translation) }
	setScaling: func (scaling: Float) -> This { this scale(scaling / this scaling) }
	setXScaling: func (scaling: Float) -> This { this scale(scaling / this scalingX, 1.0f) }
	setYScaling: func (scaling: Float) -> This { this scale(1.0f, scaling / this scalingY) }
	setRotation: func (rotation: Float) -> This { this rotate(rotation - this rotationZ) }
	translate: func (xDelta, yDelta: Float) -> This { This createTranslation(xDelta, yDelta) * this }
	translate: func ~float (delta: Float) -> This { this translate(delta, delta) }
	translate: func ~point (delta: FloatPoint2D) -> This { this translate(delta x, delta y) }
	translate: func ~vector (delta: FloatVector2D) -> This { this translate(delta x, delta y) }
	scale: func (xFactor, yFactor: Float) -> This { This createScaling(xFactor, yFactor) * this }
	scale: func ~float (factor: Float) -> This { this scale(factor, factor) }
	scale: func ~vector (factor: FloatVector2D) -> This { this scale(factor x, factor y) }
	rotate: func (angle: Float) -> This { This createZRotation(angle) * this }
	skewX: func (angle: Float) -> This { This createSkewingX(angle) * this }
	skewY: func (angle: Float) -> This { This createSkewingY(angle) * this }
	reflectX: func -> This { This createReflectionX() * this }
	reflectY: func -> This { This createReflectionY() * this }
	toString: func -> String {
		"%8f" formatFloat(this a) >> ", " & "%8f" formatFloat(this b) >> ", " & "%8f" formatFloat(this c) >> "\t" & \
		"%8f" formatFloat(this d) >> ", " & "%8f" formatFloat(this e) >> ", " & "%8f" formatFloat(this f) >> "\t" & \
		"%8f" formatFloat(this g) >> ", " & "%8f" formatFloat(this h) >> ", " & "%8f" formatFloat(this i) >> "\t"
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
		this a equals(other a) &&
		this b equals(other b) &&
		this c equals(other c) &&
		this d equals(other d) &&
		this e equals(other e) &&
		this f equals(other f) &&
		this g equals(other g) &&
		this h equals(other h) &&
		this i equals(other i)
	}
	operator != (other: This) -> Bool {
		!(this == other)
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
	operator * (other: FloatTransform3D) -> FloatTransform3D {
		thisTransform3D := FloatTransform3D new(this)
		thisTransform3D * other
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
	operator [] (x, y: Int) -> Float {
		result := 0.0f
		version (safe)
			Debug error(x < 0 || x > 2 || y < 0 || y > 2, "Out of bounds in FloatTransform2D get operator (#{x}, #{y})")
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

	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) } }

	create: static func (translation: FloatVector2D, scale, rotation: Float) -> This {
		This new(rotation cos() * scale, rotation sin() * scale, -rotation sin() * scale, rotation cos() * scale, translation x, translation y)
	}
	create: static func ~reduced (translation: FloatVector2D, rotation: Float) -> This { This create(translation, 1.0f, rotation) }
	createTranslation: static func (xDelta, yDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta) }
	createTranslation: static func ~float (delta: Float) -> This { This createTranslation(delta, delta) }
	createTranslation: static func ~vector (delta: FloatVector2D) -> This { This createTranslation(delta x, delta y) }
	createTranslation: static func ~point (delta: FloatPoint2D) -> This { This createTranslation(delta x, delta y) }
	createScaling: static func (xFactor, yFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, yFactor, 0.0f, 0.0f) }
	createScaling: static func ~float (factor: Float) -> This { This createScaling(factor, factor) }
	createScaling: static func ~vector (factor: FloatVector2D) -> This { This createScaling(factor x, factor y) }
	createZRotation: static func (angle: Float) -> This { This new(angle cos(), angle sin(), -angle sin(), angle cos(), 0.0f, 0.0f) }
	createSkewingX: static func (angle: Float) -> This { This new(1.0f, 0.0f, angle sin(), 1.0f, 0.0f, 0.0f) }
	createSkewingY: static func (angle: Float) -> This { This new(1.0f, angle sin(), 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionX: static func -> This { This new(-1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f) }
	createReflectionY: static func -> This { This new(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f) }
	referenceToNormalized: func ~float (imageSize: FloatVector2D) -> This {
		toReference := This createScaling(imageSize x / 2.0f, imageSize y / 2.0f)
		toNormalized := This createScaling(2.0f / imageSize x, 2.0f / imageSize y)
		toNormalized * this * toReference
	}
	referenceToNormalized: func ~int (imageSize: IntVector2D) -> This {
		this referenceToNormalized(imageSize toFloatVector2D())
	}
	normalizedToReference: func ~float (imageSize: FloatVector2D) -> This {
		toReference := This createScaling(imageSize x / 2.0f, imageSize y / 2.0f)
		toNormalized := This createScaling(2.0f / imageSize x, 2.0f / imageSize y)
		toReference * this * toNormalized
	}
	normalizedToReference: func ~int (imageSize: IntVector2D) -> This {
		this normalizedToReference(imageSize toFloatVector2D())
	}
}

extend Cell<FloatTransform2D> {
	toString: func ~floattransform2d -> String { (this val as FloatTransform2D) toString() }
}
