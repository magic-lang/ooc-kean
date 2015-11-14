include math
use math

PI := 3.14159_26535_89793_23846_26433_83279
FLT_EPSILON: extern Float
constantE: extern (M_E) Double
constantPi: extern (M_PI) Double

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

/* I don't think math.ooc should be a bunch of global functions,
   instead it should define a bunch of methods on the numeric
   classes. I'm going to write these methods but leave the existing
   functions alone for the sake of compatability.

   For future additions please define only methods and not the
   function versions to discourage use of the deprecated function
   versions.

   - Scott
 */
 extend Short {
	minimumValue ::= static SHRT_MIN
	maximumValue ::= static SHRT_MAX
}

extend Int64 {
	modulo: func(divisor: This) -> This { 
		result := this - (this / divisor) * divisor
		result < 0 ? result + divisor : result
	}
}

extend Int {
	modulo: func (divisor: This) -> This {
		if (divisor < 0) {
			this *= -1
			divisor *= -1
		}
		result := this % divisor
		if (result < 0)
			result += divisor
		result
	}
	clamp: func (floor: This, ceiling: This) -> This {
		if (this > ceiling)
			ceiling
		else if (this < floor)
			floor
		else
			this
	}

	negativeInfinity ::= static INT_MIN
	positiveInfinity ::= static INT_MAX
	epsilon ::= static 1
	minimumValue ::= static INT_MIN
	maximumValue ::= static INT_MAX
	pi ::= static 3
	e ::= static 2

	absolute: static func (value: This) -> This {
		value >= 0 ? value : -1 * value
	}
	sign: static func (value: This) -> This {
		value >= 0 ? 1 : -1
	}
	maximum: static func ~two (first: This, second: This) -> This {
		first > second ? first : second
	}
	// TODO: Avoid using this, consider removing it.
	maximum: static func ~multiple (value: This, values: ...) -> This {
		values each(|v|
			if ((v as This*)@ > value)
				value = v
		)
		value
	}
	minimum: static func ~two (first: This, second: This) -> This {
		first < second ? first : second
	}
	// TODO: Avoid using this, consider removing it.
	minimum: static func ~multiple (value: This, values: ...) -> This {
		values each(|v|
			if ((v as This*)@ < value)
				value = v
		)
		value
	}
	modulo: static func ~deprecated (dividend: This, divisor: This) -> This {
		dividend modulo(divisor)
	}
	odd: static func (value: This) -> Bool {
		This modulo(value, 2) == 1
	}
	even: static func (value: This) -> Bool {
		This modulo(value, 2) == 0
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
		PI / 180.0 * value
	}
	toDegrees: static func (value: This) -> This {
		180.0 / PI * value
	}
	clamp: func (floor, ceiling: Double) -> This {
		if (this > ceiling)
			ceiling
		else if (this < floor)
			floor
		else
			this
	}
}

extend Float {
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
	clamp: func (floor: This, ceiling: This) -> This {
		if (this > ceiling)
			ceiling
		else if (this < floor)
			floor
		else
			this
	}

	negativeInfinity ::= static -(INFINITY as Float)
	positiveInfinity ::= static INFINITY as Float
	epsilon ::= static FLT_EPSILON
	minimumValue ::= static FLT_MIN
	maximumValue ::= static FLT_MAX
	pi ::= static 3.14159_26535_89793_23846_26433_83279f
	e ::= static 2.718281828459045235360287471352662497757247093699959574966f

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
		if (value > 0.0f)
			1.0f
		else if (value < 0.0f)
			-1.0f
		else
			0.0f
	}
	maximum: static func (first: This, second: This) -> This {
		first > second ? first : second
	}
	minimum: static func (first: This, second: This) -> This {
		first < second ? first : second
	}
	modulo: static func (dividend: This, divisor: This) -> This {
// TODO: handle negative dividends
//		if (dividend < 0)
//			dividend += This ceiling(This absolute(dividend) / (Float) divisor) * divisor
		dividend mod(divisor)
	}
	odd: static func (value: This) -> Bool {
		This modulo(value, 2) == 1
	}
	even: static func (value: This) -> Bool {
		This modulo(value, 2) == 0
	}
	squared: func -> This {
		this * this
	}
	moduloTwoPi: static func (value: This) -> This {
		This modulo(value, 2 * This pi)
	}
	minusPiToPi: static func (value: This) -> This {
		value = This moduloTwoPi(value)
		value = (value <= This pi) ? value : (value - 2 * pi)
		value = (value >= -This pi) ? value : (value + 2 * pi)
		value
	}
	minusPiToPiOverTwo: static func (value: This) -> This {
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

extend LDouble {
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
}
