/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import IntPoint2D
import IntVector2D
import FloatVector2D
use base
use math

FloatPoint2D: cover {
	x, y: Float

	norm ::= (this x * this x + this y * this y) sqrt()
	isZero ::= this norm equals(0.0f)
	normalized ::= this isZero ? (this as This) : this / this norm
	azimuth ::= this y atan2(this x)
	absolute ::= This new(this x absolute, this y absolute)
	sign ::= This new(this x sign, this y sign)

	init: func@ (=x, =y)
	init: func@ ~sqaure (length: Float) { this x = this y = length }
	init: func@ ~default { this init(0.0f, 0.0f) }
	pNorm: func (p: Float) -> Float {
		(this x abs() pow(p) + this y abs() pow(p)) pow(1.0f / p)
	}
	scalarProduct: func (other: This) -> Float { this x * other x + this y * other y }
	angle: func (other: This) -> Float {
		(this scalarProduct(other) / (this norm * other norm)) clamp(-1, 1) acos() * (this x * other y - this y * other x < 0 ? -1 : 1)
	}
	distance: func (other: This) -> Float { (this - other) norm }
	distanceSquared: func (other: This) -> Float {
		distanceVector := this - other
		distanceVector x * distanceVector x + distanceVector y * distanceVector y
	}
	swap: func -> This { This new(this y, this x) }
	round: func -> This { This new(this x round(), this y round()) }
	ceiling: func -> This { This new(this x ceil(), this y ceil()) }
	floor: func -> This { This new(this x floor(), this y floor()) }
	minimum: func (ceiling: This) -> This { This new(this x minimum(ceiling x), this y minimum(ceiling y)) }
	maximum: func (floor: This) -> This { This new(this x maximum(floor x), this y maximum(floor y)) }
	clamp: func (floor, ceiling: This) -> This { This new(this x clamp(floor x, ceiling x), this y clamp(floor y, ceiling y)) }
	polar: static func (radius, azimuth: Float) -> This { This new(radius * cos(azimuth), radius * sin(azimuth)) }
	toIntPoint2D: func -> IntPoint2D { IntPoint2D new(this x as Int, this y as Int) }
	toIntVector2D: func -> IntVector2D { IntVector2D new(this x as Int, this y as Int) }
	toFloatVector2D: func -> FloatVector2D { FloatVector2D new(this x, this y) }
	toString: func (decimals := 2) -> String { (this x toString(decimals) >> ", ") & this y toString(decimals) }

	operator - -> This { This new(-this x, -this y) }
	operator + (other: This) -> This { This new(this x + other x, this y + other y) }
	operator - (other: This) -> This { This new(this x - other x, this y - other y) }
	operator * (other: This) -> This { This new(this x * other x, this y * other y) }
	operator / (other: This) -> This { This new(this x / other x, this y / other y) }
	operator < (other: This) -> Bool { this x < other x && this y < other y }
	operator > (other: This) -> Bool { this x > other x && this y > other y }
	operator <= (other: This) -> Bool { this x <= other x && this y <= other y }
	operator >= (other: This) -> Bool { this x >= other x && this y >= other y }
	operator == (other: This) -> Bool { this x equals(other x) && this y equals(other y) }
	operator != (other: This) -> Bool { !(this == other) }
	operator + (other: FloatVector2D) -> This { This new(this x + other x, this y + other y) }
	operator - (other: FloatVector2D) -> This { This new(this x - other x, this y - other y) }
	operator * (other: FloatVector2D) -> This { This new(this x * other x, this y * other y) }
	operator / (other: FloatVector2D) -> This { This new(this x / other x, this y / other y) }
	operator * (other: Float) -> This { This new(this x * other, this y * other) }
	operator / (other: Float) -> This { This new(this x / other, this y / other) }

	basisX: static This { get { This new(1, 0) } }
	basisY: static This { get { This new(0, 1) } }

	parse: static func (input: String) -> This {
		parts := input split(',')
		result := This new(parts[0] toFloat(), parts[1] toFloat())
		parts free()
		result
	}
	mix: static func (a, b: This, ratio: Float) -> This {
		This new(Float mix(a x, b x, ratio), Float mix(a y, b y, ratio))
	}
}
operator * (left: Float, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left * right x, left * right y) }
operator / (left: Float, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left / right x, left / right y) }
operator * (left: Int, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left * right x, left * right y) }
operator / (left: Int, right: FloatPoint2D) -> FloatPoint2D { FloatPoint2D new(left / right x, left / right y) }

extend Cell<FloatPoint2D> {
	toString: func ~floatpoint2d -> String { (this val as FloatPoint2D) toString() }
}
