//
// Copyright (c) 2011-2012 Anders Frisk
// Copyright (c) 2012-2015 Simon Mika <simon@mika.se>
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
import structs/ArrayList
use ooc-base

FloatComplex: cover {
	real, imaginary: Float
	init: func@ (=real, =imaginary)
	init: func@ ~default { this init(0.0f, 0.0f) }
	conjugate ::= This new(this real, - this imaginary)
	absoluteValue ::= (this real pow(2) + this imaginary pow(2)) sqrt()
	operator + (other: This) -> This { This new(this real + other real, this imaginary + other imaginary) }
	operator - (other: This) -> This { This new(this real - other real, this imaginary - other imaginary) }
	operator - -> This { This new(-this real, -this imaginary) }
	operator * (other: Float) -> This { This new(other * this real, other * this imaginary) }
	operator * (other: This) -> This {
		This new(
			this real * other real - this imaginary * other imaginary,
			this real * other imaginary + this imaginary * other real
		)
	}
	operator / (other: Float) -> This { This new(this real / other, this imaginary / other) }
	operator / (other: This) -> This { (this * other conjugate) / (other absoluteValue pow(2)) }
	operator == (other: This) -> Bool { this real == other real && this imaginary == other imaginary }
	operator != (other: This) -> Bool { !(this == other) }
	toString: func -> String {
		this real toString() >> (this imaginary > 0 ? " +" : " ") & this imaginary toString() >> "i"
	}
	parse: static func (input: Text) -> This {
		array := input find('+') >= 0 ? input split('+') : input split(' ')
		result := This new(array[0] toFloat(), array[1] toFloat())
		array free()
		result
	}
	exponential: func -> This {
		(this real) exp() * This new((this imaginary) cos(), (this imaginary) sin())
	}
	logarithm: func -> This {
		This new(this absoluteValue log(), this imaginary atan2(this real))
	}
	rootOfUnity: static func (n: Int, k := 1) -> This {
		This new(0.0f, 2.0f * k * Float pi / n) exponential()
	}
}
operator * (left: Float, right: FloatComplex) -> FloatComplex { FloatComplex new(left * right real, left * right imaginary) }
operator / (left: Float, right: FloatComplex) -> FloatComplex { (left * right conjugate) / (right absoluteValue pow(2)) }
