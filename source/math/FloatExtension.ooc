import ./internal
import math

extend Float {
	clamp: func(floor: This, ceiling: This) -> This {
		if (this > ceiling)
			ceiling
		else if (this < floor)
			floor
		else
			this
	}
	// Static Properties
	negativeInfinity ::= static -(INFINITY as Float)
	positiveInfinity ::= static INFINITY as Float
	epsilon ::= static FLT_EPSILON
	minimumValue ::= static FLT_MIN
	maximumValue ::= static FLT_MAX
	pi ::= static 3.14159_26535_89793_23846_26433_83279f
	e ::= static 2.718281828459045235360287471352662497757247093699959574966f
	// Static Utility Functions
	// parse: static func(value: String) -> This { This parse(value, 0) }
	// parse: static func(value: String, default: This) -> This { }
//	toString: static func(value: This) -> String {
//		value toString()
//	}
	absolute: static func(value: This) -> This {
		value >= 0 ? value : -1 * value
	}
	sign: static func(value: This) -> This {
		if (value > 0.0f)
			1.0f
		else if (value < 0.0f)
			-1.0f
		else
			0.0f
	}
	maximum: static func(first: This, second: This) -> This {
		first > second ? first : second
	}
	minimum: static func(first: This, second: This) -> This {
		first < second ? first : second
	}
	modulo: static func(dividend: This, divisor: This) -> This {
// TODO: handle negative dividends
//		if (dividend < 0)
//			dividend += This ceiling(This absolute(dividend) / (Float) divisor) * divisor
		dividend mod(divisor)
	}
	odd: static func(value: This) -> Bool {
		This modulo(value, 2) == 1
	}
	even: static func(value: This) -> Bool {
		This modulo(value, 2) == 0
	}
	squared: func -> This {
		this * this
	}
	moduloTwoPi: static func(value: This) -> This {
		This modulo(value, 2 * This pi)
	}
	minusPiToPi: static func(value: This) -> This {
		value = This moduloTwoPi(value)
		value = (value <= This pi) ? value : (value - 2 * pi)
		value = (value >= -This pi) ? value : (value + 2 * pi)
		value
	}
	minusPiToPiOverTwo: static func(value: This) -> This {
		value = modulo(value, This pi)
		value = (value <= This pi / 2) ? value : (value - pi)
		value = (value >= -This pi / 2) ? value : (value + pi)
		value
	}
	// Linear interpolation between a and b using ratio
	//   lerp(a, b, 0) = a
	//   lerp(a, b, 0.5) = (a + b) / 2
	//   lerp(a, b, 1) = b
	//   lerp(a, a, x) = a
	// Called "lerp" in CG and HLSL, called "mix" in GLSL
	linearInterpolation: static func (a: This, b: This, ratio: This) -> This {
		(ratio * (b - a)) + a
	}
	// Inverse to lerp returning ratio given the same a and b
	// Precondition: a and b have different values
	//   Getting +inf, -inf or NaN shows when the precondition is broken
	// Postcondition: inverseLerp(a, b, lerp(a, b, r)) = r
	inverseLinearInterpolation: static func (a: This, b: This, value: This) -> This {
		(value - a) / (b - a)
	}
	decomposeToCoefficientAndRadix: static func (value: This, valueDigits: Int) -> (This, This) {
		radix := 1.0f
		if (value != 0.0f) {
			while (This absolute(value) >= pow(10.0f, valueDigits)) {
				value /= 10.0f
				radix *= 10.0f
			}
			while (This absolute(value) - pow(10.0f, valueDigits-1) < - This epsilon) {
				value *= 10.0f
				radix /= 10.0f
			}
		}
		coefficient := value
		(coefficient, radix)
	}
	roundToValueDigits: static func (value: This, valueDigits: Int, up: Bool) -> This {
		(result, radix) := This decomposeToCoefficientAndRadix(value, valueDigits)
		if (result != 0) {
			result = up ? ceil(result) : floor(result)
			result *= radix
		}
		result
	}
	getRadix: static func (value: This, valueDigits: Int) -> This {
		(tempValue, result) := This decomposeToCoefficientAndRadix(value, valueDigits)
		result
	}
	getScientificPowerString: static func (value: This) -> String {
		(coefficient, radix) := This decomposeToCoefficientAndRadix(value, 1)
		power := log10(radix) as Int
		result := coefficient toString() >> "E" & power toString()
		result
	}
}
