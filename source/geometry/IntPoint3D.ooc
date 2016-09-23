/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import IntPoint2D
import IntVector3D
import FloatPoint3D
import FloatVector3D
use base

IntPoint3D: cover {
	x, y, z: Int

	isZero ::= this x == 0 && this y == 0 && this z == 0
	norm ::= ((this x squared + this y squared + this z squared) as Float sqrt())
	absolute ::= This new(this x absolute, this y absolute, this z absolute)
	sign ::= This new(this x sign, this y sign, this z sign)

	init: func@ (=x, =y, =z)
	init: func@ ~cube (length: Int) { this x = this y = this z = length }
	init: func@ ~default { this init(0, 0, 0) }
	init: func@ ~fromPoint2D (point: IntPoint2D, z := 0) { this init(point x, point y, z) }
	distance: func (other: This) -> Float { (this - other) toFloatPoint3D() norm }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y + this z * other z }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y), this z minimum(ceiling z)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y), this z maximum(floor z)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y), this z clamp(floor z, ceiling z)) }
	toIntVector3D: func -> IntVector3D { IntVector3D new(this x, this y, this z) }
	toFloatPoint3D: func -> FloatPoint3D { FloatPoint3D new(this x as Float, this y as Float, this z as Float) }
	toFloatVector3D: func -> FloatVector3D { FloatVector3D new(this x as Float, this y as Float, this z as Float) }
	toString: func -> String { (this x toString() >> ", ") & (this y toString() >> ", ") & this z toString() }

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
	operator != (other: This) -> Bool { this x != other x || this y != other y || this z != other z }
	operator + (other: IntVector3D) -> This { This new(this x + other x, this y + other y, this z + other z) }
	operator - (other: IntVector3D) -> This { This new(this x - other x, this y - other y, this z - other z) }
	operator * (other: IntVector3D) -> This { This new(this x * other x, this y * other y, this z * other z) }
	operator / (other: IntVector3D) -> This { This new(this x / other x, this y / other y, this z / other z) }
	operator * (other: Int) -> This { This new(this x * other, this y * other, this z * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other, this z / other) }

	parse: static func (input: String) -> This {
		parts := input split(',')
		result := This new(parts[0] toInt(), parts[1] toInt(), parts[2] toInt())
		parts free()
		result
	}
}
operator * (left: Int, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Int, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left / right x, left / right y, left / right z) }
operator * (left: Float, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left * right x, left * right y, left * right z) }
operator / (left: Float, right: IntPoint3D) -> IntPoint3D { IntPoint3D new(left / right x, left / right y, left / right z) }

extend Cell<IntPoint3D> {
	toString: func ~intpoint3d -> String { (this val as IntPoint3D) toString() }
}
