/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import IntVector2D
import FloatPoint2D
use base
use math

IntPoint2D: cover {
	x, y: Int

	init: func@ (=x, =y)
	init: func@ ~default { this init(0, 0) }
	scalarProduct: func (other: This) -> Int { this x * other x + this y * other y }
	swap: func -> This { This new(this y, this x) }
	distance: func (other: This) -> Float { (this - other) toFloatPoint2D() norm }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	toFloatPoint2D: func -> FloatPoint2D { FloatPoint2D new(this x as Float, this y as Float) }
	toString: func -> String { "#{this x toString()}, #{this y toString()}" }
	toText: func -> Text { this x toText() + t", " + this y toText() }

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
	operator != (other: This) -> Bool { this x != other x || this y != other y }
	operator + (other: IntVector2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: IntVector2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: IntVector2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: IntVector2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Int) -> This { This new(this x * other, this y * other) }
	operator / (other: Int) -> This { This new(this x / other, this y / other) }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toInt(), parts[1] toInt())
		parts free()
		result
	}
}
operator * (left: Int, right: IntPoint2D) -> IntPoint2D { IntPoint2D new(left * right x, left * right y) }
operator / (left: Int, right: IntPoint2D) -> IntPoint2D { IntPoint2D new(left / right x, left / right y) }
operator * (left: Float, right: IntPoint2D) -> IntPoint2D { IntPoint2D new(left * right x, left * right y) }
operator / (left: Float, right: IntPoint2D) -> IntPoint2D { IntPoint2D new(left / right x, left / right y) }
