use ooc-unit
import math

MathTest: class extends Fixture {
	init: func {
		super("Math")
		tolerance := 1.0e-5f
		this add("Modulo", func {
			// Note: Negative values are in parentheses because of bug in rock
			expect(22 modulo(5), is equal to(2))
			expect((-7) modulo(3), is equal to(2))
			expect((-7) modulo(1), is equal to(0))
			expect(0 modulo(3), is equal to(0))
			expect(3 modulo(4), is equal to(3))
			expect((-1) modulo(2), is equal to(1))
			expect(8 modulo(8), is equal to(0))

			int64ValuePos: Int64 = 22
			int64ValueNeg: Int64 = -7
			expect(int64ValuePos modulo(5), is equal to(2))
			expect(int64ValueNeg modulo(3), is equal to(2))
			expect(int64ValueNeg modulo(1), is equal to(0))

			expect(22.3f modulo(5), is equal to(2.3f) within(tolerance))
			expect((-7.3f) modulo(3), is equal to(1.7f) within(tolerance))
			expect(4.1f modulo(4.2f), is equal to(4.1f) within(tolerance))
		})
	}
}

MathTest new() run() . free()
