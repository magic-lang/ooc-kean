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
		value >= 0 ? 1 : -1
	}
	maximum: static func(first: This, second: This) -> This {
		first > second ? first : second
	}
	maximum: static func ~multiple(value: This, values: ...) -> This {
		values each(|v|
			if ((v as This) > value)
				value = v
		)
		value
	}
	minimum: static func(first: This, second: This) -> This {
		first < second ? first : second
	}
	minimum: static func ~multiple(value: This, values: ...) -> This {
		values each(|v|
			if ((v as This) < value)
				value = v
		)
		value
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
		value
	}
}
