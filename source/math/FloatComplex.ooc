/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base

FloatComplex: cover {
	real, imaginary: Float

	conjugate ::= This new(this real, - this imaginary)
	absoluteValue ::= (this real pow(2) + this imaginary pow(2)) sqrt()

	init: func@ (=real, =imaginary)
	init: func@ ~default { this init(0.0f, 0.0f) }
	toString: func (decimals := 2) -> String {
		this real toString(decimals) >> (this imaginary > 0 ? " +" : " ") & this imaginary toString(decimals) >> "i"
	}
	exponential: func -> This {
		(this real) exp() * This new((this imaginary) cos(), (this imaginary) sin())
	}
	logarithm: func -> This {
		This new(this absoluteValue log(), this imaginary atan2(this real))
	}

	operator - -> This { This new(-this real, -this imaginary) }
	operator + (other: This) -> This { This new(this real + other real, this imaginary + other imaginary) }
	operator - (other: This) -> This { This new(this real - other real, this imaginary - other imaginary) }
	operator * (other: This) -> This { This new(this real * other real - this imaginary * other imaginary, this real * other imaginary + this imaginary * other real) }
	operator / (other: This) -> This { (this * other conjugate) / (other absoluteValue pow(2)) }
	operator == (other: This) -> Bool { this real equals(other real) && this imaginary equals(other imaginary) }
	operator != (other: This) -> Bool { !(this == other) }
	operator * (other: Float) -> This { This new(other * this real, other * this imaginary) }
	operator / (other: Float) -> This { This new(this real / other, this imaginary / other) }

	parse: static func (input: String) -> This {
		parts := input find("+") >= 0 ? input split('+') : input split(' ')
		result := This new(parts[0] toFloat(), parts[1] toFloat())
		parts free()
		result
	}
	rootOfUnity: static func (n: Int, k := 1) -> This {
		This new(0.0f, 2.0f * k * Float pi / n) exponential()
	}
}
operator * (left: Float, right: FloatComplex) -> FloatComplex { FloatComplex new(left * right real, left * right imaginary) }
operator / (left: Float, right: FloatComplex) -> FloatComplex { (left * right conjugate) / (right absoluteValue pow(2)) }

extend Cell<FloatComplex> {
	toString: func ~floatcomplex -> String { (this val as FloatComplex) toString() }
}
