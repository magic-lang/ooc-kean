/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import IntPoint2D
import FloatPoint2D
import FloatVector2D
use base

IntVector2D: cover {
	x, y: Int

	area ::= this x * this y
	hasZeroArea ::= this area == 0
	square ::= this x == this y
	norm ::= ((this x squared + this y squared) as Float sqrt())
	isZero ::= this x == 0 && this y == 0
	absolute ::= This new(this x absolute, this y absolute)
	sign ::= This new(this x sign, this y sign)

	init: func@ (=x, =y)
	init: func@ ~square (length: Int) { this x = this y = length }
	init: func@ ~default { this init(0, 0) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y }
	swap: func -> This { This new(this y, this x) }
	distance: func (other: This) -> Float { (this - other) norm }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	minimum: func ~Int (ceiling: Int) -> This { this minimum(This new(ceiling)) }
	maximum: func ~Int (floor: Int) -> This { this maximum(This new(floor)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	polar: static func (radius, azimuth: Float) -> This { This new((radius * cos(azimuth)) as Int, (radius * sin(azimuth)) as Int) }
	toIntPoint2D: func -> IntPoint2D { IntPoint2D new(this x, this y) }
	toFloatVector2D: func -> FloatVector2D { FloatVector2D new(this x as Float, this y as Float) }
	toFloatPoint2D: func -> FloatPoint2D { FloatPoint2D new(this x as Float, this y as Float) }
	toString: func -> String { (this x toString() >> ", ") & this y toString() }

	operator - -> This { This new(-this x, -this y) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y) }
	operator < (other: This) -> Bool { this x < other x && this y < other y }
	operator > (other: This) -> Bool { this x > other x && this y > other y }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y }
	operator == (other: This) -> Bool { this x == other x && this y == other y }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: IntPoint2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: IntPoint2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: IntPoint2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: IntPoint2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Float) -> This { This new(this x * other, this y * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other) }
	operator * (other: Int) -> This { This new(this x * other, this y * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other) }

	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }

	parse: static func (input: String) -> This {
		parts := input split(',')
		result := This new (parts[0] toInt(), parts[1] toInt())
		parts free()
		result
	}
}
operator * (left: Int, right: IntVector2D) -> IntVector2D { IntVector2D new(left * right x, left * right y) }
operator / (left: Int, right: IntVector2D) -> IntVector2D { IntVector2D new(left / right x, left / right y) }
operator * (left: Float, right: IntVector2D) -> IntVector2D { IntVector2D new(left * right x, left * right y) }
operator / (left: Float, right: IntVector2D) -> IntVector2D { IntVector2D new(left / right x, left / right y) }

extend Cell<IntVector2D> {
	toString: func ~intvector2d -> String { (this val as IntVector2D) toString() }
}
