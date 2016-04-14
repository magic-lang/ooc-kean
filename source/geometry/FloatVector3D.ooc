/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use math
import FloatPoint3D
import IntPoint3D
import IntVector3D
use base

FloatVector3D: cover {
	x, y, z: Float

	volume ::= this x * this y * this z
	hasZeroVolume ::= this volume equals(0.0f)
	length ::= this norm
	norm ::= (this x squared + this y squared + this z squared) sqrt()
	normalized ::= this / this norm
	isZero ::= this norm equals(0.0f)
	azimuth ::= this y atan2(this x)

	init: func@ (=x, =y, =z)
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this x abs() pow(p) + this y abs() pow(p) + this z abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y + this z * other z }
	vectorProduct: func (other: This) -> This {
		This new(
			this y * other z - other y * this z,
			-(this x * other z - other x * this z),
			this x * other y - other x * this y
		)
	}
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1.0f, 1.0f) acos() * (this x * other y - this y * other x < 0.0f ? -1.0f : 1.0f)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	round: func -> This { This new(this x round(), this y round(), this z round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil(), this z ceil()) }
	floor: func -> This { This new(this x floor(), this y floor(), this z floor()) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y), this z minimum(ceiling z)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y), this z maximum(floor z)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	limitLength: func (maximum: Float) -> This { this norm > maximum ? this normalized * maximum : this }
	toIntVector3D: func -> IntVector3D { IntVector3D new(this x as Int, this y as Int, this z as Int) }
	toFloatPoint3D: func -> FloatPoint3D { FloatPoint3D new(this x, this y, this z) }
	toString: func -> String { "#{this x toString()}, #{this y toString()}, #{this z toString()}" }
	toText: func -> Text { this x toText() + t", " + this y toText() + t", " + this z toText() }

	operator - -> This { This new(-this x, -this y, -this z) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator < (other: This) -> Bool { this x < other x && this y < other y && this z < other z }
	operator > (other: This) -> Bool { this x > other x && this y > other y && this z > other z }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y && this z <= other z }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y && this z >= other z }
	operator == (other: This) -> Bool { this x equals(other x) && this y equals(other y) && this z equals(other z) }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: FloatPoint3D) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: FloatPoint3D) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator * (other: FloatPoint3D) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: FloatPoint3D) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other, this z / other) }

	basisX: static This { get { This new(1, 0, 0) } }
	basisY: static This { get { This new(0, 1, 0) } }
	basisZ: static This { get { This new(0, 0, 1) } }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toFloat(), parts[1] toFloat(), parts[2] toFloat())
		parts free()
		result
	}
	linearInterpolation: static func (a, b: This, ratio: Float) -> This {
		This new(ratio linearInterpolation(a x, b x), ratio linearInterpolation(a y, b y), ratio linearInterpolation(a z, b z))
	}
}
operator * (left: Float, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left / right x, left / right y, left / right z) }
operator * (left: Int, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: FloatVector3D) -> FloatVector3D { FloatVector3D new(left / right x, left / right y, left / right z) }

extend Cell<FloatVector3D> {
	toText: func ~floatvector3d -> Text { (this val as FloatVector3D) toText() }
}
