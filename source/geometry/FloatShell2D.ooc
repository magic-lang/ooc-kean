/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use math
import FloatPoint2D
import FloatVector2D
import FloatBox2D
use base

FloatShell2D: cover {
	left, right, top, bottom: Float

	leftTop ::= FloatPoint2D new(this left, this top)
	size ::= FloatVector2D new(this left + this right, this top + this bottom)
	balance ::= FloatPoint2D new(this right - this left, this bottom - this top)
	isZero ::= this left == 0 && this right == 0 && this top == 0 && this bottom == 0
	notZero ::= this left != 0 && this right != 0 && this top != 0 && this bottom != 0

	init: func@ (=left, =right, =top, =bottom)
	init: func@ ~fromFloat (value: Float) { this init(value, value, value, value) }
	init: func@ ~fromFloats (x, y: Float) { this init(x, x, y, y) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f) }
	decrease: func (size: FloatVector2D) -> FloatBox2D { FloatBox2D new(this left, this top, size x - this left - this right, size y - this top - this bottom) }
	increase: func (size: FloatVector2D) -> FloatBox2D { FloatBox2D new(-this left, -this right, size x + this left + this right, size y + this top + this bottom) }
	decrease: func ~byBox (box: FloatBox2D) -> FloatBox2D {
		FloatBox2D new(box leftTop x + this left, box leftTop y + this top, box size x - this left - this right, box size y - this top - this bottom)
	}
	increase: func ~byBox (box: FloatBox2D) -> FloatBox2D {
		FloatBox2D new(box leftTop x - this left, box leftTop y - this top, box size x + this left + this right, box size y + this top + this bottom)
	}
	maximum: func (other: This) -> This {
		This new(this left maximum(other left), this right maximum(other right), this top maximum(other top), this bottom maximum(other bottom))
	}
	minimum: func (other: This) -> This {
		This new(this left minimum(other left), this right minimum(other right), this top minimum(other top), this bottom minimum(other bottom))
	}
	toString: func (decimals := 2) -> String { (this left toString(decimals) >> ", ") & (this right toString(decimals) >> ", ") & (this top toString(decimals) >> ", ") & (this bottom toString(decimals) >> ", ") }

	operator + (other: This) -> This { This new(this left + other left, this right + other right, this top + other top, this bottom + other bottom) }
	operator - (other: This) -> This { This new(this left - other left, this right - other right, this top - other top, this bottom - other bottom) }
	operator == (other: This) -> Bool { this left equals(other left) && this right equals(other right) && this top equals(other top) && this bottom equals(other bottom) }
	operator != (other: This) -> Bool { !(this == other) }
	operator / (other: Float) -> This { This new(this left / other, this right / other, this top / other, this bottom / other) }

	parse: static func (input: String) -> This {
		parts := input split(',')
		result := This new(parts[0] toFloat(), parts[1] toFloat(), parts[2] toFloat(), parts[3] toFloat())
		parts free()
		result
	}
}

extend Cell<FloatShell2D> {
	toString: func ~floatshell2d -> String { (this val as FloatShell2D) toString() }
}
