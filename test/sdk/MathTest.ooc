use ooc-unit

MathTest: class extends Fixture {
	init: func {
		super("Math")
		floatTolerance := 1.0e-5f
		doubleTolerance := 1.0e-5
		this add("Int64", func {
			int64ValuePos: Int64 = 22
			int64ValueNeg: Int64 = -7
			expect(int64ValuePos modulo(5), is equal to(2))
			expect(int64ValueNeg modulo(3), is equal to(2))
			expect(int64ValueNeg modulo(1), is equal to(0))
		})
		this add("Int", func {
			expect(22 modulo(5), is equal to(2))
			expect((-7) modulo(3), is equal to(2)) // (-7) within parentheses because of bug in rock
			expect((-7) modulo(1), is equal to(0))
			expect(0 modulo(3), is equal to(0))
			expect(3 modulo(4), is equal to(3))
			expect((-1) modulo(2), is equal to(1))
			expect(8 modulo(8), is equal to(0))

			expect(10 clamp(8, 14), is equal to(10))
			expect(7 clamp(9, 11), is equal to(9))
			expect(13 clamp(9, 11), is equal to(11))
			expect((-2) clamp(-1, 5), is equal to(-1))

			expect((-3) absolute, is equal to(3))
			expect(1 absolute, is equal to(1))

			expect((-3) sign, is equal to(-1))
			expect(3 sign, is equal to(1))

			expect((-1) maximum(1), is equal to(1))
			expect((-1) maximum(0), is equal to(0))
			expect((-1) minimum(1), is equal to(-1))
			expect((-1) minimum(0), is equal to(-1))

			expect(2 isEven, is true)
			expect((-4) isEven, is true)
			expect(0 isOdd, is false)
			expect((-5) isOdd, is true)
			expect(7 isEven, is false)

			expect(5 squared, is equal to((-5) squared))

			expect(62 alignPowerOfTwo(64), is equal to(64))
			expect(137 alignPowerOfTwo(128), is equal to(256))

			expect(12345 digits(), is equal to(5))
		})
		this add("Float", func {
			expect(22.3f modulo(5), is equal to(2.3f) within(floatTolerance))
			expect((-7.3f) modulo(3), is equal to(1.7f) within(floatTolerance))
			expect(4.1f modulo(4.2f), is equal to(4.1f) within(floatTolerance))

			expect(0.0f toRadians(), is equal to(0.0f) within(floatTolerance))
			expect(45.0f toRadians(), is equal to(0.78539f) within(floatTolerance))
			expect(3.1415926535f toDegrees(), is equal to(180.0f) within(floatTolerance))

			expect(10.0f clamp(8.0f, 14.0f), is equal to(10.0f) within(floatTolerance))
			expect(7.0f clamp(9.0f, 11.0f), is equal to(9.0f) within(floatTolerance))
			expect(13.0f clamp(9.0f, 11.0f), is equal to(11.0f) within(floatTolerance))
			expect((-2.0f) clamp(-1.9f, 5.0f), is equal to(-1.9f) within(floatTolerance)) // (-2.0f) with parentheses because of bug in rock

			expect(1.9999999f equals(2.0f), is false)
			expect(1.99999999f equals(2.0f), is true)

			expect((-2.3f) absolute, is equal to(2.3f) within(floatTolerance))
			expect(2.3f absolute, is equal to(2.3f) within(floatTolerance))

			expect((-2.3f) sign, is equal to(-1.0f) within(floatTolerance))
			expect(2.3f sign, is equal to(1.0f) within(floatTolerance))

			expect((-1.2f) maximum(-1.1f), is equal to(-1.1f) within(floatTolerance))
			expect((-1.2f) maximum(0.f), is equal to(0.f) within(floatTolerance))
			expect((-1.2f) minimum(-1.1f), is equal to(-1.2f) within(floatTolerance))
			expect((-1.2f) minimum(0.f), is equal to(-1.2f) within(floatTolerance))

			expect(10.f squared, is equal to(100.f) within(floatTolerance))

			expect(0.5f linearInterpolation(2.0f, 5.0f), is equal to(3.5f) within(floatTolerance))
			expect(0.1f linearInterpolation(-9.0f, 1.0f), is equal to(-8.f) within(floatTolerance))

			nearZero := (0.1f + 0.1f + 0.1f) - 0.3f
			expect(nearZero equals(0.0f), is true)
			expect(nearZero lessOrEqual(0.0f), is true)
			expect(nearZero greaterOrEqual(0.0f), is true)
			expect(nearZero greaterThan(0.0f), is false)
			expect(nearZero lessThan(0.0f), is false)

			nearZero = 0.3f - (0.1f + 0.1f + 0.1f)
			expect(nearZero equals(0.0f), is true)
			expect(nearZero lessOrEqual(0.0f), is true)
			expect(nearZero greaterOrEqual(0.0f), is true)
			expect(nearZero greaterThan(0.0f), is false)
			expect(nearZero lessThan(0.0f), is false)

			(coefficient, radix) := 120.f decomposeToCoefficientAndRadix(1)
			expect(coefficient, is equal to(1.2f) within(floatTolerance))
			expect(radix, is equal to(100.f) within(floatTolerance))
			secondRadix := 120.f getRadix(1)
			expect(radix, is equal to(secondRadix) within(floatTolerance))
			expect(123.456f getScientificPowerString(), is equal to("1.23E2"))
			expect(123.4f roundToValueDigits(2, true), is equal to(130.f) within(floatTolerance))
			expect(123.4f roundToValueDigits(3, false), is equal to(123.f) within(floatTolerance))
		})
		this add("Double", func {
			expect(22.3 modulo(5), is equal to(2.3) within(doubleTolerance))
			expect((-7.3) modulo(3), is equal to(1.7) within(doubleTolerance))
			expect(4.1 modulo(4.2), is equal to(4.1) within(doubleTolerance))

			expect(0.0 toRadians(), is equal to(0.0) within(doubleTolerance))
			expect(45.0 toRadians(), is equal to(0.78539) within(doubleTolerance))
			expect(3.1415926535 toDegrees(), is equal to(180.0) within(doubleTolerance))

			expect(10.0 clamp(8.0, 14.0), is equal to(10.0) within(doubleTolerance))
			expect(7.0 clamp(9.0, 11.0), is equal to(9.0) within(doubleTolerance))
			expect(13.0 clamp(9.0, 11.0), is equal to(11.0) within(doubleTolerance))
			expect((-2.0) clamp(-1.9, 5.0), is equal to(-1.9) within(doubleTolerance)) // (-2.0) with parentheses because of bug in rock

			expect(1.999999999999999 equals(2.0), is false)
			expect(1.9999999999999999 equals(2.0), is true)

			nearZero := (0.1 + 0.1 + 0.1) - 0.3
			expect(nearZero equals(0.0), is true)
			expect(nearZero lessOrEqual(0.0), is true)
			expect(nearZero greaterOrEqual(0.0), is true)
			expect(nearZero greaterThan(0.0), is false)
			expect(nearZero lessThan(0.0), is false)

			nearZero = 0.3 - (0.1 + 0.1 + 0.1)
			expect(nearZero equals(0.0), is true)
			expect(nearZero lessOrEqual(0.0), is true)
			expect(nearZero greaterOrEqual(0.0), is true)
			expect(nearZero greaterThan(0.0), is false)
			expect(nearZero lessThan(0.0), is false)
		})
	}
}

MathTest new() run() . free()
