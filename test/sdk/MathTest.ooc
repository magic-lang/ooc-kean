use ooc-unit
import math

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
			
			expect(Int absolute(-3), is equal to(3))
			expect(Int absolute(1), is equal to(1))
			
			expect(Int sign(-3), is equal to(-1))
			expect(Int sign(3), is equal to(1))
			
			expect(Int maximum(-1, 1), is equal to(1))
			expect(Int maximum(-1, 0), is equal to(0))
			expect(Int minimum(-1, 1), is equal to(-1))
			expect(Int minimum(-1, 0), is equal to(-1))
			
			expect(Int even(2), is true)
			expect(Int even(-4), is true)
			expect(Int odd(0), is false)
			expect(Int odd(-5), is true)
			expect(Int even(7), is false)
			
			expect(5 squared(), is equal to((-5) squared()))
			
			expect(Int toPowerOfTwo(7), is equal to(8))
			expect(Int alignPowerOfTwo(62, 64), is equal to(64))
			expect(Int alignPowerOfTwo(137, 128), is equal to(256))
		})
		this add("Float", func {
			expect(22.3f modulo(5), is equal to(2.3f) within(floatTolerance))
			expect((-7.3f) modulo(3), is equal to(1.7f) within(floatTolerance))
			expect(4.1f modulo(4.2f), is equal to(4.1f) within(floatTolerance))
			expect(Float moduloTwoPi(6.29f), is equal to(0.0f) within(0.01f))
			
			expect(Float toRadians(0.0f), is equal to(0.0f) within(floatTolerance))
			expect(Float toRadians(45.0f), is equal to(0.78539f) within(floatTolerance))
			expect(Float toDegrees(3.1415926535f), is equal to(180.0f) within(floatTolerance))
			
			expect(10.0f clamp(8.0f, 14.0f), is equal to(10.0f) within(floatTolerance))
			expect(7.0f clamp(9.0f, 11.0f), is equal to(9.0f) within(floatTolerance))
			expect(13.0f clamp(9.0f, 11.0f), is equal to(11.0f) within(floatTolerance))
			expect((-2.0f) clamp(-1.9f, 5.0f), is equal to(-1.9f) within(floatTolerance)) // (-2.0f) with parentheses because of bug in rock
			
			expect(1.999f equals(2.0f), is false)
			expect(1.99999f equals(2.0f), is true)
			
			expect(Float absolute(-2.3f), is equal to(2.3f) within(floatTolerance))
			expect(Float absolute(2.3f), is equal to(2.3f) within(floatTolerance))
			
			expect(Float sign(-2.3f), is equal to(-1.0f) within(floatTolerance))
			expect(Float sign(2.3f), is equal to(1.0f) within(floatTolerance))
			
			expect(Float maximum(-1.2f, -1.1f), is equal to(-1.1f) within(floatTolerance))
			expect(Float maximum(-1.2f, 0.f), is equal to(0.f) within(floatTolerance))
			expect(Float minimum(-1.2f, -1.1f), is equal to(-1.2f) within(floatTolerance))
			expect(Float minimum(-1.2f, 0.f), is equal to(-1.2f) within(floatTolerance))
			
			expect(10.f squared(), is equal to(100.f) within(floatTolerance))
			
			expect(Float linearInterpolation(2.0f, 5.0f, 0.5f), is equal to(3.5f) within(floatTolerance))
			expect(Float linearInterpolation(-9.0f, 1.0f, 0.1f), is equal to(-8.f) within(floatTolerance))
		})
		this add("Double", func {
			expect(Double toRadians(0.0), is equal to(0.0) within(doubleTolerance))
			expect(Double toRadians(45.0), is equal to(0.78539) within(doubleTolerance))
			expect(Double toDegrees(3.1415926535), is equal to(180.0) within(doubleTolerance))
			
			expect(10.0 clamp(8.0, 14.0), is equal to(10.0) within(doubleTolerance))
			expect(7.0 clamp(9.0, 11.0), is equal to(9.0) within(doubleTolerance))
			expect(13.0 clamp(9.0, 11.0), is equal to(11.0) within(doubleTolerance))
			expect((-2.0) clamp(-1.9, 5.0), is equal to(-1.9) within(doubleTolerance)) // (-2.0) with parentheses because of bug in rock
			
			expect(1.999 equals(2.0), is false)
			expect(1.99999 equals(2.0), is true)
		})
	}
}

MathTest new() run() . free()
