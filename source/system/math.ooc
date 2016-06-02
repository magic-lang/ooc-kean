/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include math

FLT_EPSILON: extern Float
DBL_EPSILON: extern Double

// These functions are kept global to make mathematical code easier to read
cos: extern (cosf) func (Float) -> Float
sin: extern (sinf) func (Float) -> Float
tan: extern (tanf) func (Float) -> Float
acos: extern (acosf) func (Float) -> Float
asin: extern (asinf) func (Float) -> Float
atan: extern (atanf) func (Float) -> Float
sqrt: extern (sqrtf) func (Float) -> Float

extend Long {
	modulo: func (divisor: This) -> This {
		result := this - (this / divisor) * divisor
		result < 0 ? result + divisor : result
	}
	maximum: func (other: This) -> This { this > other ? this : other }
	minimum: func (other: This) -> This { this < other ? this : other }
}
extend ULong {
	maximum: func (other: This) -> This { this > other ? this : other }
	minimum: func (other: This) -> This { this < other ? this : other }
}

extend Int {
	absolute ::= this >= 0 ? this : -1 * this
	sign ::= this >= 0 ? 1 : -1
	isOdd ::= this modulo(2) == 1
	isEven ::= this modulo(2) == 0
	squared ::= this * this

	pow: func (other: This) -> This { (this as Float) pow(other as Float) as Int }
	clamp: func (floor, ceiling: This) -> This { this > ceiling ? ceiling : (this < floor ? floor : this) }
	modulo: func (divisor: This) -> This {
		result := this
		if (result < 0)
			result += (((result abs() as Float) / divisor) ceil() as Int) * divisor
		result % divisor
	}
	digits: func -> This {
		result := this < 0 ? 2 : 1
		value := this absolute
		while (value >= 10) {
			result += 1
			value /= 10
		}
		result
	}
	align: func (align: Int) -> This {
		result := this
		if (align > 0) {
			remainder := this % align
			if (remainder > 0)
				result = this + align - remainder
		}
		result
	}
	alignPowerOfTwo: func (align: Int) -> This {
		align > 0 ? (this + align - 1) & ~(align - 1) : this
	}

	maximum: func (other: This) -> This { this > other ? this : other }
	minimum: func (other: This) -> This { this < other ? this : other }
}

extend Double {
	negativeInfinity ::= static -INFINITY
	positiveInfinity ::= static INFINITY
	minimumValue ::= static DBL_MIN
	maximumValue ::= static DBL_MAX
	epsilon ::= static DBL_EPSILON
	pi ::= static 3.14159_26535_89793_23846_26433_83279
	e ::= static 2.718281828459045235360287471352662497757247093699959574966
	absolute ::= this >= 0.f ? this : -1.0 * this
	sign ::= this >= 0.0 ? 1.0 : -1.0
	isOdd ::= this modulo(2) == 1
	isEven ::= this modulo(2) == 0
	squared ::= this * this

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

	modulo: func (divisor: This) -> This {
		result := this
		if (result < 0)
			result += ((result abs()) / divisor) ceil() * divisor
		result mod(divisor)
	}
	toRadians: func -> This { This pi / 180.0 * this }
	toDegrees: func -> This { 180.0 / This pi * this }
	clamp: func (floor, ceiling: This) -> This { this > ceiling ? ceiling : (this < floor ? floor : this) }
	equals: func (other: This, tolerance := This epsilon) -> Bool { (this - other) abs() < tolerance }
	lessThan: func (other: This, tolerance := This epsilon) -> Bool { this < other && !this equals(other, tolerance) }
	greaterThan: func (other: This, tolerance := This epsilon) -> Bool { this > other && !this equals(other, tolerance) }
	lessOrEqual: func (other: This, tolerance := This epsilon) -> Bool { !this greaterThan(other, tolerance) }
	greaterOrEqual: func (other: This, tolerance := This epsilon) -> Bool { !this lessThan(other, tolerance) }

	maximum: func (other: This) -> This { this > other ? this : other }
	minimum: func (other: This) -> This { this < other ? this : other }
}

extend Float {
	negativeInfinity ::= static -(INFINITY as Float)
	positiveInfinity ::= static INFINITY as Float
	minimumValue ::= static FLT_MIN
	maximumValue ::= static FLT_MAX
	epsilon ::= static FLT_EPSILON
	pi ::= static 3.14159_26535_89793_23846_26433_83279f
	e ::= static 2.718281828459045235360287471352662497757247093699959574966f
	absolute ::= this >= 0.f ? this : -1.f * this
	sign ::= this >= 0.f ? 1.f : -1.f
	isOdd ::= this modulo(2) == 1
	isEven ::= this modulo(2) == 0
	squared ::= this * this

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

	equals: func (other: This, tolerance := This epsilon) -> Bool { (this - other) abs() < tolerance }
	lessThan: func (other: This, tolerance := This epsilon) -> Bool { this < other && !this equals(other, tolerance) }
	greaterThan: func (other: This, tolerance := This epsilon) -> Bool { this > other && !this equals(other, tolerance) }
	lessOrEqual: func (other: This, tolerance := This epsilon) -> Bool { !this greaterThan(other, tolerance) }
	greaterOrEqual: func (other: This, tolerance := This epsilon) -> Bool { !this lessThan(other, tolerance) }
	mix: static func (a, b, ratio: This) -> This { (ratio * (b - a)) + a }
	inverseMix: static func (a, b, ratio: This) -> This { (ratio - a) / (b - a) }
	clamp: func (floor, ceiling: This) -> This { this > ceiling ? ceiling : (this < floor ? floor : this) }
	toRadians: func -> This { This pi / 180.0f * this }
	toDegrees: func -> This { 180.0f / This pi * this }
	modulo: func (divisor: This) -> This {
		result := this
		if (result < 0)
			result += ((result abs()) / divisor) ceil() * divisor
		result mod(divisor)
	}
	decomposeToCoefficientAndRadix: func (valueDigits: Int) -> (This, This) {
		radix := 1.0f
		value := this
		if (value != 0.0f) {
			while (value absolute >= 10.0f pow(valueDigits)) {
				value /= 10.0f
				radix *= 10.0f
			}
			while (value absolute - 10.0f pow(valueDigits-1) < -This epsilon) {
				value *= 10.0f
				radix /= 10.0f
			}
		}
		coefficient := value
		(coefficient, radix)
	}
	roundToValueDigits: func (valueDigits: Int, up: Bool) -> This {
		(result, radix) := this decomposeToCoefficientAndRadix(valueDigits)
		if (result != 0) {
			result = up ? result ceil() : result floor()
			result *= radix
		}
		result
	}
	getRadix: func (valueDigits: Int) -> This {
		(tempValue, result) := this decomposeToCoefficientAndRadix(valueDigits)
		result
	}
	getScientificPowerString: func -> String {
		(coefficient, radix) := this decomposeToCoefficientAndRadix(1)
		power := radix log10() as Int
		result := coefficient toString() >> "E" & power toString()
		result
	}
	sineInterpolation: func -> Float {
		absoluteValue := this absolute
		absoluteValue > 1.f ? 1.f : (sin((absoluteValue - 0.5f) * This pi) + 1.0f) / 2.0f
	}

	maximum: func (other: This) -> This { this > other ? this : other }
	minimum: func (other: This) -> This { this < other ? this : other }
}

extend LDouble {
	pi ::= static 3.14159_26535_89793_23846_26433_83279L
	e ::= static 2.718281828459045235360287471352662497757247093699959574966L
	defaultTolerance ::= static 0.0001L

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

	equals: func (other: This, tolerance := This defaultTolerance) -> Bool { (this - other) abs() < tolerance }
	lessThan: func (other: This, tolerance := This defaultTolerance) -> Bool { this < other && !this equals(other, tolerance) }
	greaterThan: func (other: This, tolerance := This defaultTolerance) -> Bool { this > other && !this equals(other, tolerance) }
	lessOrEqual: func (other: This, tolerance := This defaultTolerance) -> Bool { !this greaterThan(other, tolerance) }
	greaterOrEqual: func (other: This, tolerance := This defaultTolerance) -> Bool { !this lessThan(other, tolerance) }
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
