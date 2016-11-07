/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use math
import IntVector2D
import FloatVector2D
import FloatVector3D
import FloatPoint2D
import FloatPoint3D
import FloatBox2D
import FloatTransform2D

// The 3D transform is a 4x4 homogeneous coordinate matrix.
// The element order is:
// A E I M
// B F J N
// C G K O
// D H L P

FloatTransform3D: cover {
	a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p: Float

	translation ::= FloatVector3D new(this m, this n, this o)
	scaling ::= (this scalingX + this scalingY + this scalingZ) / 3.0f
	scalingX ::= (this a squared + this b squared + this c squared) sqrt()
	scalingY ::= (this e squared + this f squared + this g squared) sqrt()
	scalingZ ::= (this i squared + this j squared + this k squared) sqrt()
	determinant: Float { get {
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
	inverse: This { get {
		determinant := this determinant
		// If the determinant is 0, the resulting transform will be full of NaN values.
		// No FloatTransform3D instance should have a determinant of 0, so
		// throw an exception, because something has gone wrong, somewhere.
		if (determinant == 0)
			Debug error("Determinant is zero in FloatTransform3D inverse()")
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
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f) }
	init: func@ ~fromFloatTransform2D (transform: FloatTransform2D) {
		this init(transform a, transform b, 0.0f, transform c, transform d, transform e, 0.0f, transform f, 0.0f, 0.0f, 1.0f, 0.0f, transform g, transform h, 0.0f, transform i)
	}
	setScaling: func (scaling: Float) -> This { this scale(scaling / this scaling) }
	setXScaling: func (scaling: Float) -> This { this scale(scaling / this scalingX, 1.0f, 1.0f) }
	setYScaling: func (scaling: Float) -> This { this scale(1.0f, scaling / this scalingY, 1.0f) }
	setZScaling: func (scaling: Float) -> This { this scale(1.0f, 1.0f, scaling / this scalingZ) }
	translate: func (xDelta, yDelta, zDelta: Float) -> This { This createTranslation(xDelta, yDelta, zDelta) * this }
	translate: func ~float (delta: Float) -> This { this translate(delta, delta, delta) }
	translate: func ~point (delta: FloatPoint3D) -> This { this translate(delta x, delta y, delta z) }
	translate: func ~vector (delta: FloatVector3D) -> This { this translate(delta x, delta y, delta z) }
	scale: func (xFactor, yFactor, zFactor: Float) -> This { This createScaling(xFactor, yFactor, zFactor) * this }
	scale: func ~float (factor: Float) -> This { this scale(factor, factor, factor) }
	scale: func ~vector (factor: FloatVector3D) -> This { this scale(factor x, factor y, factor z) }
	rotateX: func (angle: Float) -> This { This createRotationX(angle) * this }
	rotateY: func (angle: Float) -> This { This createRotationY(angle) * this }
	rotateZ: func (angle: Float) -> This { This createRotationZ(angle) * this }
	reflectX: func -> This { This createReflectionX() * this }
	reflectY: func -> This { This createReflectionY() * this }
	reflectZ: func -> This { This createReflectionZ() * this }
	toString: func -> String {
		"%.8f" formatFloat(this a) >> ", " & "%.8f" formatFloat(this e) >> ", " & "%.8f" formatFloat(this i) >> ", " & "%.8f" formatFloat(this m) >> "\n" & \
		"%.8f" formatFloat(this b) >> ", " & "%.8f" formatFloat(this f) >> ", " & "%.8f" formatFloat(this j) >> ", " & "%.8f" formatFloat(this n) >> "\n" & \
		"%.8f" formatFloat(this c) >> ", " & "%.8f" formatFloat(this g) >> ", " & "%.8f" formatFloat(this k) >> ", " & "%.8f" formatFloat(this o) >> "\n" & \
		"%.8f" formatFloat(this d) >> ", " & "%.8f" formatFloat(this h) >> ", " & "%.8f" formatFloat(this l) >> ", " & "%.8f" formatFloat(this p)
	}
	transformAndProject: func ~FloatPoint2D (point: FloatPoint2D, focalLength: Float) -> FloatPoint2D {
		transformedWorldPoint := this * FloatPoint3D new(point x, point y, focalLength)
		focalLength < Float epsilon ? FloatPoint2D new(transformedWorldPoint x, transformedWorldPoint y) : this project(transformedWorldPoint, focalLength)
	}
	transformAndProject: func ~FloatBox2D (box: FloatBox2D, focalLength: Float) -> FloatBox2D {
		FloatBox2D new(this transformAndProject(box leftTop, focalLength), this transformAndProject(box rightBottom, focalLength))
	}
	transformAndProjectCorners: func (box: FloatBox2D, focalLength: Float) -> VectorList<FloatPoint2D> {
		result := VectorList<FloatPoint2D> new()
		result add(this transformAndProject(box leftTop, focalLength))
		result add(this transformAndProject(box leftBottom, focalLength))
		result add(this transformAndProject(box rightBottom, focalLength))
		result add(this transformAndProject(box rightTop, focalLength))
		result
	}
	project: func (point: FloatPoint3D, focalLength: Float) -> FloatPoint2D {
		projectedPoint := This createProjection(focalLength) * point / point z
		FloatPoint2D new(projectedPoint x, projectedPoint y)
	}

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
	operator == (other: This) -> Bool {
		this a equals(other a) &&
		this b equals(other b) &&
		this c equals(other c) &&
		this d equals(other d) &&
		this e equals(other e) &&
		this f equals(other f) &&
		this g equals(other g) &&
		this h equals(other h) &&
		this i equals(other i) &&
		this j equals(other j) &&
		this k equals(other k) &&
		this l equals(other l) &&
		this m equals(other m) &&
		this n equals(other n) &&
		this o equals(other o) &&
		this p equals(other p)
	}
	operator != (other: This) -> Bool {
		!(this == other)
	}
	operator [] (x, y: Int) -> Float {
		result := 0.0f
		version (safe)
			Debug error(x < 0 || x > 3 || y < 0 || y > 3, "Out of bounds in FloatTransform3D get operator (#{x}, #{y})")
		match (x) {
			case 0 =>
				match (y) {
					case 0 => result = this a
					case 1 => result = this b
					case 2 => result = this c
					case 3 => result = this d
				}
			case 1 =>
				match (y) {
					case 0 => result = this e
					case 1 => result = this f
					case 2 => result = this g
					case 3 => result = this h
				}
			case 2 =>
				match (y) {
					case 0 => result = this i
					case 1 => result = this j
					case 2 => result = this k
					case 3 => result = this l
				}
			case 3 =>
				match (y) {
					case 0 => result = this m
					case 1 => result = this n
					case 2 => result = this o
					case 3 => result = this p
				}
		}
		result
	}
	operator * (other: FloatPoint3D) -> FloatPoint3D {
		FloatPoint3D new(
			this a * other x + this e * other y + this i * other z + this m,
			this b * other x + this f * other y + this j * other z + this n,
			this c * other x + this g * other y + this k * other z + this o
		)
	}
	operator * (other: FloatTransform2D) -> This {
		otherTransform3D := This new(other)
		this * otherTransform3D
	}

	identity: static This { get { This new(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f) } }

	create: static func (a, b, c, d, e, f, g, h, i, j, k, l: Float) -> This { This new(a, b, c, d, e, f, g, h, i, j, k, l) }
	createTranslation: static func (xDelta, yDelta, zDelta: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, xDelta, yDelta, zDelta) }
	createTranslation: static func ~float (delta: Float) -> This { This createTranslation(delta, delta, delta) }
	createTranslation: static func ~vector (delta: FloatVector3D) -> This { This createTranslation(delta x, delta y, delta z) }
	createTranslation: static func ~point (delta: FloatPoint3D) -> This { This createTranslation(delta x, delta y, delta z) }
	createScaling: static func (xFactor, yFactor, zFactor: Float) -> This { This new(xFactor, 0.0f, 0.0f, 0.0f, yFactor, 0.0f, 0.0f, 0.0f, zFactor, 0.0f, 0.0f, 0.0f) }
	createScaling: static func ~float (factor: Float) -> This { This createScaling(factor, factor, factor) }
	createScaling: static func ~vector (factor: FloatVector3D) -> This { This createScaling(factor x, factor y, factor z) }
	createRotationX: static func (angle: Float) -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationY: static func (angle: Float) -> This { This new(angle cos(), 0.0f, (-angle) sin(), 0.0f, 1.0f, 0.0f, angle sin(), 0.0f, angle cos(), 0.0f, 0.0f, 0.0f) }
	createRotationZ: static func (angle: Float) -> This { This new(angle cos(), angle sin(), 0.0f, (-angle) sin(), angle cos(), 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createRotation: static func ~pivot (transform: This, pivot: FloatPoint3D) -> This {
		This createTranslation(pivot x, pivot y, pivot z) * transform * This createTranslation(-pivot x, -pivot y, -pivot z)
	}
	createReflectionX: static func -> This { This new(-1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionY: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f) }
	createReflectionZ: static func -> This { This new(1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f) }
	createProjection: static func (focalLength: Float) -> This {
		This new(focalLength, 0, 0, 0, 0, focalLength, 0, 0, 0, 0, focalLength, 1.0f, 0, 0, 0, 0)
	}
	referenceToNormalized: func ~float (imageSize: FloatVector2D) -> This {
		toReference := This createScaling(imageSize x / 2.0f, imageSize y / 2.0f, imageSize x / 2.0f)
		toNormalized := This createScaling(2.0f / imageSize x, 2.0f / imageSize y, 2.0f / imageSize x)
		toNormalized * this * toReference
	}
	referenceToNormalized: func ~int (imageSize: IntVector2D) -> This {
		this referenceToNormalized(imageSize toFloatVector2D())
	}
	normalizedToReference: func ~float (imageSize: FloatVector2D) -> This {
		toReference := This createScaling(imageSize x / 2.0f, imageSize y / 2.0f, imageSize x / 2.0f)
		toNormalized := This createScaling(2.0f / imageSize x, 2.0f / imageSize y, 2.0f / imageSize x)
		toReference * this * toNormalized
	}
	normalizedToReference: func ~int (imageSize: IntVector2D) -> This {
		this normalizedToReference(imageSize toFloatVector2D())
	}
}

extend Cell<FloatTransform3D> {
	toString: func ~floattransform3d -> String { (this val as FloatTransform3D) toString() }
}
