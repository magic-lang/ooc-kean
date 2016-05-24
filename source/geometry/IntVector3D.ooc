/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import IntPoint3D
import FloatVector3D
use base

IntVector3D: cover {
	x, y, z: Int

	volume ::= this x * this y * this z
	hasZeroVolume ::= this volume == 0

	init: func@ (=x, =y, =z)
	init: func@ ~default { this init(0, 0, 0) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y + this z * other z }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y), this z minimum(ceiling z)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y), this z maximum(floor z)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	toFloatVector3D: func -> FloatVector3D { FloatVector3D new(this x as Float, this y as Float, this z as Float) }
	toString: func -> String { (this x toString() >> ", ") & (this y toString() >> ", ") & this z toString() }
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
	operator == (other: This) -> Bool { this x == other x && this y == other y && this z == other z }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: IntPoint3D) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: IntPoint3D) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator * (other: IntPoint3D) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: IntPoint3D) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Float) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other, this z / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other, this z / other) }

	basisX: static This { get { This new(1, 0, 0) } }
	basisY: static This { get { This new(0, 1, 0) } }
	basisZ: static This { get { This new(0, 0, 1) } }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new (parts[0] toInt(), parts[1] toInt(), parts[2] toInt())
		parts free()
		result
	}
}
operator * (left: Int, right: IntVector3D) -> IntVector3D { IntVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: IntVector3D) -> IntVector3D { IntVector3D new(left / right x, left / right y, left / right z) }
operator * (left: Float, right: IntVector3D) -> IntVector3D { IntVector3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: IntVector3D) -> IntVector3D { IntVector3D new(left / right x, left / right y, left / right z) }

extend Cell<IntVector3D> {
	toText: func ~intvector3d -> Text { (this val as IntVector3D) toText() }
}
