include math
use math

FLT_EPSILON: extern Float

abs: extern func (Int) -> Int

cos: extern func (Double) -> Double
sin: extern func (Double) -> Double
tan: extern func (Double) -> Double

acos: extern func (Double) -> Double
asin: extern func (Double) -> Double
atan: extern func (Double) -> Double

atan2: extern func (Double, Double) -> Double

sqrt: extern func (Double) -> Double
pow: extern func (Double, Double) -> Double

log: extern (log) func ~Double (Double) -> Double
log: extern (logf) func ~Float (Float) -> Float
log: extern (logl) func ~Long (LDouble) -> LDouble

log2: extern (log2) func ~Double (Double) -> Double
log2: extern (log2f) func ~Float (Float) -> Float
log2: extern (log2l) func ~Long (LDouble) -> LDouble

log10: extern (log10) func ~Double (Double) -> Double
log10: extern (log10f) func ~Float (Float) -> Float
log10: extern (log10l) func ~Long (LDouble) -> LDouble

round: extern (lround) func ~dl (Double) -> Long

ceil: extern (ceil) func ~Double (Double) -> Double
ceil: extern (ceilf) func ~Float (Float) -> Float
ceil: extern (ceill) func ~Long (LDouble) -> LDouble

floor: extern (floor) func ~Double (Double) -> Double
floor: extern (floorf) func ~Float (Float) -> Float
floor: extern (floorl) func ~Long (LDouble) -> LDouble

//TODO: Define methods only on extensions, and avoid global functions. Most of them should be non-static

extend Short {
	minimumValue ::= static SHRT_MIN
	maximumValue ::= static SHRT_MAX
}

extend Int64 {
	modulo: func (divisor: This) -> This {
		result := this - (this / divisor) * divisor
		result < 0 ? result + divisor : result
	}
}

extend Int {
	negativeInfinity ::= static INT_MIN
	positiveInfinity ::= static INT_MAX
	epsilon ::= static 1
	minimumValue ::= static INT_MIN
	maximumValue ::= static INT_MAX
	pi ::= static 3
	e ::= static 2
	
	modulo: func (divisor: This) -> This {
		result := this
		if (result < 0)
			result += (((result abs() as Float) / divisor) ceil() as Int) * divisor
		result % divisor
	}
	clamp: func (floor, ceiling: This) -> This {
		this > ceiling ? ceiling : (this < floor ? floor : this)
	}
	absolute: static func (value: This) -> This {
		value >= 0 ? value : -1 * value
	}
	sign: static func (value: This) -> This {
		value >= 0 ? 1 : -1
	}
	maximum: static func (first, second: This) -> This {
		first > second ? first : second
	}
	minimum: static func (first, second: This) -> This {
		first < second ? first : second
	}
	odd: static func (value: This) -> Bool {
		value modulo(2) == 1
	}
	even: static func (value: This) -> Bool {
		value modulo(2) == 0
	}
	squared: func -> This {
		this * this
	}
	align: static func (x, align: Int) -> This {
		result := x
		if (align > 0) {
			remainder := x % align
			if (remainder > 0)
				result = x + align - remainder
		}
		result
	}
	alignPowerOfTwo: static func (x, align: Int) -> This { align > 0 ? (x + align - 1) & ~(align - 1) : x }
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

extend Range {
	clamp: func (floor, ceiling: Int) -> This {
		this clamp(floor .. ceiling)
	}
	clamp: func ~range (other: This) -> This {
		this min clamp(other min, other max) .. this max clamp(other min, other max)
	}
	count ::= this max + 1 - this min
}
operator - (range: Range, integer: Int) -> Range { (range min - integer) .. (range max - integer) }
operator + (range: Range, integer: Int) -> Range { (range min + integer) .. (range max + integer) }
operator == (left, right: Range) -> Bool { left min == right min && left max == right max }
operator != (left, right: Range) -> Bool { !(left == right) }

extend Double {
	pi ::= static 3.14159_26535_89793_23846_26433_83279
	e ::= static 2.718281828459045235360287471352662497757247093699959574966
	
	cos: extern (cos) func -> This
	sin: extern (sin) func -> This
	tan: extern (tan) func -> This
	acos: extern (acos) func -> This
	asin: extern (asin) func -> This
	atan: extern (atan) func -> This
	cosh: extern (cosh) func -> This
	sinh: extern (sinh) func -> This
	tanh: extern (tanh) func -> This
	acosh: extern (acosh) func -> This
	asinh: extern (asinh) func -> This
	atanh: extern (atanh) func -> This
	atan2: extern (atan2) func (This) -> This

	sqrt: extern (sqrt) func -> This
	cbrt: extern (cbrt) func -> This
	abs: extern (fabs) func -> This
	pow: extern (pow) func (This) -> This
	exp: extern (exp) func -> This

	log: extern (log) func -> This
	log2: extern (log2) func -> This
	log10: extern (log10) func -> This

	mod: extern (fmod) func (This) -> This

	round: extern (round) func -> This
	roundLong: extern (lround) func -> Long
	roundLLong: extern (llround) func -> LLong
	ceil: extern (ceil) func -> This
	floor: extern (floor) func -> This
	truncate: extern (trunc) func -> This

	toRadians: static func (value: This) -> This {
		This pi / 180.0 * value
	}
	toDegrees: static func (value: This) -> This {
		180.0 / This pi * value
	}
	clamp: func (floor, ceiling: This) -> This {
		this > ceiling ? ceiling : (this < floor ? floor : this)
	}
	equals: func (other: This, tolerance := 0.0001) -> Bool { (this - other) abs() < tolerance }
}

extend Float {
	negativeInfinity ::= static -(INFINITY as Float)
	positiveInfinity ::= static INFINITY as Float
	epsilon ::= static FLT_EPSILON
	minimumValue ::= static FLT_MIN
	maximumValue ::= static FLT_MAX
	pi ::= static 3.14159_26535_89793_23846_26433_83279f
	e ::= static 2.718281828459045235360287471352662497757247093699959574966f
	
	cos: extern (cosf) func -> This
	sin: extern (sinf) func -> This
	tan: extern (tanf) func -> This
	acos: extern (acosf) func -> This
	asin: extern (asinf) func -> This
	atan: extern (atanf) func -> This
	cosh: extern (coshf) func -> This
	sinh: extern (sinhf) func -> This
	tanh: extern (tanhf) func -> This
	acosh: extern (acoshf) func -> This
	asinh: extern (asinhf) func -> This
	atanh: extern (atanhf) func -> This
	atan2: extern (atan2f) func (This) -> This

	sqrt: extern (sqrtf) func -> This
	cbrt: extern (cbrtf) func -> This
	abs: extern (fabsf) func -> This
	pow: extern (powf) func (This) -> This
	exp: extern (expf) func -> This

	log: extern (logf) func -> This
	log2: extern (log2f) func -> This
	log10: extern (log10f) func -> This

	mod: extern (fmodf) func (This) -> This

	round: extern (roundf) func -> This
	roundLong: extern (lroundf) func -> Long
	roundLLong: extern (llroundf) func -> LLong
	ceil: extern (ceilf) func -> This
	floor: extern (floorf) func -> This
	truncate: extern (truncf) func -> This
	clamp: func (floor, ceiling: This) -> This {
		this > ceiling ? ceiling : (this < floor ? floor : this)
	}
	toRadians: static func (value: This) -> This {
		This pi / 180.0f * value
	}
	toDegrees: static func (value: This) -> This {
		180.0f / This pi * value
	}
	absolute: static func (value: This) -> This {
		value >= 0 ? value : -1 * value
	}
	sign: static func (value: This) -> This {
		value > 0.0f ? 1.0f : (value < 0.0f ? -1.0f : 0.0f)
	}
	maximum: static func (first, second: This) -> This {
		first > second ? first : second
	}
	minimum: static func (first, second: This) -> This {
		first < second ? first : second
	}
	modulo: func (divisor: This) -> This {
		result := this
		if (result < 0)
			result += ((result abs()) / divisor) ceil() * divisor
		result mod(divisor)
	}
	odd: static func (value: This) -> Bool {
		value modulo(2) == 1
	}
	even: static func (value: This) -> Bool {
		value modulo(2) == 0
	}
	squared: func -> This {
		this * this
	}
	moduloTwoPi: static func (value: This) -> This {
		value modulo(2.0f * This pi)
	}
	minusPiToPi: static func (value: This) -> This {
		value = This moduloTwoPi(value)
		value = (value <= This pi) ? value : (value - 2 * pi)
		value = (value >= -This pi) ? value : (value + 2 * pi)
		value
	}
	minusPiToPiOverTwo: static func (value: This) -> This {
		value = value modulo(This pi)
		value = (value <= This pi / 2) ? value : (value - pi)
		value = (value >= -This pi / 2) ? value : (value + pi)
		value
	}
	linearInterpolation: static func (a: This, b: This, ratio: This) -> This {
		(ratio * (b - a)) + a
	}
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
	equals: func (other: This, tolerance := 0.0001f) -> Bool { (this - other) abs() < tolerance }
}

extend LDouble {
	pi ::= static 3.14159_26535_89793_23846_26433_83279L
	e ::= static 2.718281828459045235360287471352662497757247093699959574966L
	
	cos: extern (cosl) func -> This
	sin: extern (sinl) func -> This
	tan: extern (tanl) func -> This
	acos: extern (acosl) func -> This
	asin: extern (asinl) func -> This
	atan: extern (atanl) func -> This
	cosh: extern (coshl) func -> This
	sinh: extern (sinhl) func -> This
	tanh: extern (tanhl) func -> This
	acosh: extern (acoshl) func -> This
	asinh: extern (asinhl) func -> This
	atanh: extern (atanhl) func -> This
	atan2: extern (atan2l) func (This) -> This

	sqrt: extern (sqrtl) func -> This
	cbrt: extern (cbrtl) func -> This
	abs: extern (fabsl) func -> This
	pow: extern (powl) func (This) -> This
	exp: extern (expl) func -> This

	log: extern (logl) func -> This
	log2: extern (log2l) func -> This
	log10: extern (log10l) func -> This

	mod: extern (fmodl) func (This) -> This

	round: extern (roundl) func -> This
	roundLong: extern (lroundl) func -> Long
	roundLLong: extern (llroundl) func -> LLong
	ceil: extern (ceill) func -> This
	floor: extern (floorl) func -> This
	truncate: extern (truncl) func -> This
	equals: func (other: This, tolerance := 0.0001) -> Bool { (this - other) abs() < tolerance }
}
