import math

extend Int {
	clamp: func(floor: This, ceiling: This) -> This {
		if (this > ceiling)
			ceiling
		else if (this < floor)
			floor
		else
			this
	}
	// Static Properties
	negativeInfinity ::= static INT_MIN
	positiveInfinity ::= static INT_MAX
	epsilon ::= static 1
	minimumValue ::= static INT_MIN
	maximumValue ::= static INT_MAX
	pi ::= static 3
	e ::= static 2
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
	maximum: static func ~two(first: This, second: This) -> This {
		first > second ? first : second
	}
	// TODO: Avoid using this, consider removing it.
	maximum: static func ~multiple(value: This, values: ...) -> This {
		values each(|v|
			if ((v as This*)@ > value)
				value = v
		)
		value
	}
	minimum: static func ~two(first: This, second: This) -> This {
		first < second ? first : second
	}
	// TODO: Avoid using this, consider removing it.
	minimum: static func ~multiple(value: This, values: ...) -> This {
		values each(|v|
			if ((v as This*)@ < value)
				value = v
		)
		value
	}
	modulo: static func ~deprecated (dividend: This, divisor: This) -> This {
		dividend modulo(divisor)
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
	align: static func (x: Int, align: Int) -> This {
		result := x
		if (align > 0) {
			remainder := x % align
			if (remainder > 0) {
				result = x + align - remainder
			}
		}
		result
	}
	toPowerOfTwo: static func (x: Int) -> This {
		result := x == 0 ? 0 : 1
		while (result < x)
			result *= 2
		result
	}
	digits: static func (x: Int) -> This {
		result := x < 0 ? 2 : 1
		value := This abs(x)
		while (value >= 10) {
			result += 1
			value /= 10
		}
		result
	}
}
