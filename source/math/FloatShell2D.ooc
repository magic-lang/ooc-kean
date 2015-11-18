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
import math
import FloatPoint2D
import FloatSize2D
import FloatBox2D
use ooc-base

FloatShell2D: cover {
	left, right, top, bottom: Float
	leftTop ::= FloatPoint2D new(this left, this top)
	size ::= FloatSize2D new(this left + this right, this top + this bottom)
	balance ::= FloatPoint2D new(this right - this left, this bottom - this top)
	isZero ::= this left == 0 && this right == 0 && this top == 0 && this bottom == 0
	notZero ::= this left != 0 && this right != 0 && this top != 0 && this bottom != 0
	init: func@ (=left, =right, =top, =bottom)
	init: func@ ~fromFloat (value: Float) { this init(value, value, value, value) }
	init: func@ ~fromFloats (x, y: Float) { this init(x, x, y, y) }
	init: func@ ~default { this init(0.0f, 0.0f, 0.0f, 0.0f) }
	decrease: func (size: FloatSize2D) -> FloatBox2D { FloatBox2D new(this left, this top, size width - this left - this right, size height - this top - this bottom) }
	increase: func (size: FloatSize2D) -> FloatBox2D { FloatBox2D new(-this left, -this right, size width + this left + this right, size height + this top + this bottom) }
	decrease: func ~byBox (box: FloatBox2D) -> FloatBox2D {
		FloatBox2D new(box leftTop x + this left, box leftTop y + this top, box size width - this left - this right, box size height - this top - this bottom)
	}
	increase: func ~byBox (box: FloatBox2D) -> FloatBox2D {
		FloatBox2D new(box leftTop x - this left, box leftTop y - this top, box size width + this left + this right, box size height + this top + this bottom)
	}
	operator + (other: This) -> This { This new(this left + other left, this right + other right, this top + other top, this bottom + other bottom) }
	operator - (other: This) -> This { This new(this left - other left, this right - other right, this top - other top, this bottom - other bottom) }
	operator / (other: Float) -> This { This new(this left / other, this right / other, this top / other, this bottom / other) }
	maximum: func (other: This) -> This {
		This new(Float maximum(this left, other left), Float maximum(this right, other right), Float maximum(this top, other top), Float maximum(this bottom, other bottom))
	}
	minimum: func (other: This) -> This {
		This new(Float minimum(this left, other left), Float minimum(this right, other right), Float minimum(this top, other top), Float minimum(this bottom, other bottom))
	}
	operator == (other: This) -> Bool { this left == other left && this right == other right && this top == other top && this bottom == other bottom }
	operator != (other: This) -> Bool { !(this == other) }
	operator as -> String { this toString() }
	toString: func -> String { "#{this left toString()}, #{this right toString()}, #{this top toString()}, #{this bottom toString()}" }
	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toFloat(), parts[1] toFloat(), parts[2] toFloat(), parts[3] toFloat())
		parts free()
		result
	}
}
