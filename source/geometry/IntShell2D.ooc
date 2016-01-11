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

import IntPoint2D
import IntVector2D
import IntBox2D
use ooc-base

IntShell2D: cover {
	left, right, top, bottom: Int

	leftTop ::= IntPoint2D new(this left, this top)
	size ::= IntVector2D new(this left + this right, this top + this bottom)
	balance ::= IntPoint2D new(this right - this left, this bottom - this top)
	isZero ::= this left == 0 && this right == 0 && this top == 0 && this bottom == 0
	notZero ::= this left != 0 && this right != 0 && this top != 0 && this bottom != 0

	init: func@ (=left, =right, =top, =bottom)
	init: func@ ~fromFloat (value: Int) { this init(value, value) }
	init: func@ ~fromFloats (x, y: Int) { this init(x, x, y, y) }
	init: func@ ~default { this init(0) }
	decrease: func (size: IntVector2D) -> IntBox2D { IntBox2D new(this left, this top, size x - this left - this right, size y - this top - this bottom) }
	increase: func (size: IntVector2D) -> IntBox2D { IntBox2D new(-this left, -this right, size x + this left + this right, size y + this top + this bottom) }
	decrease: func ~byBox (box: IntBox2D) -> IntBox2D {
		IntBox2D new(box leftTop x + this left, box leftTop y + this top, box size x - this left - this right, box size y - this top - this bottom)
	}
	increase: func ~byBox (box: IntBox2D) -> IntBox2D {
		IntBox2D new(box leftTop x - this left, box leftTop y - this top, box size x + this left + this right, box size y + this top + this bottom)
	}
	maximum: func (other: This) -> This {
		This new(this left maximum(other left), this right maximum(other right), this top maximum(other top), this bottom maximum(other bottom))
	}
	minimum: func (other: This) -> This {
		This new(this left minimum(other left), this right minimum(other right), this top minimum(other top), this bottom minimum(other bottom))
	}
	toString: func -> String { "#{this left toString()}, #{this right toString()}, #{this top toString()}, #{this bottom toString()}" }
	toText: func -> Text { this left toText() + t", " + this right toText() + t", " + this top toText() + t", " + this bottom toText() }

	operator + (other: This) -> This { This new(this left + other left, this right + other right, this top + other top, this bottom + other bottom) }
	operator - (other: This) -> This { This new(this left - other left, this right - other right, this top - other top, this bottom - other bottom) }
	operator == (other: This) -> Bool { this left == other left && this right == other right && this top == other top && this bottom == other bottom }
	operator != (other: This) -> Bool { !(this == other) }
	operator / (other: Int) -> This { This new(this left / other, this right / other, this top / other, this bottom / other) }

	parse: static func (input: Text) -> This {
		parts := input split(',')
		result := This new(parts[0] toInt(), parts[1] toInt(), parts[2] toInt(), parts[3] toInt())
		parts free()
		result
	}
}
