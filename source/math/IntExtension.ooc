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
	minimum: static func ~multiple(value: This, values: ...) -> This {
		values each(|v|
			if ((v as This*)@ < value)
				value = v
		)
		value
	}
	modulo: static func(dividend: This, divisor: This) -> This {
// TODO: handle negative dividends
//		if (dividend < 0)
//			dividend += This ceiling(This absolute(dividend) / (Float) divisor) * divisor
		dividend % divisor
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
		align > 0 ? (x + align - 1) & ~(align - 1) : x
	}
}
