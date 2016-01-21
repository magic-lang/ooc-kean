use unit
use math

FloatExtensionTest: class extends Fixture {
	precision := 1.0e-5f
	init: func {
		super("FloatExtension")
		this add("decompose to coefficient and radix", func {
			(coefficient, radix) := 3333.0f decomposeToCoefficientAndRadix(2)
			expect(coefficient, is equal to(33.33f) within(this precision))
			expect(radix, is equal to(100.0f) within(this precision))
			(coefficient, radix) = 0.3333f decomposeToCoefficientAndRadix(2)
			expect(coefficient, is equal to(33.33f) within(this precision))
			expect(radix, is equal to(0.01f) within(this precision))
		})
		this add("round to value digits", func {
			expect(3333.0f roundToValueDigits(2, false), is equal to(3300.0f) within(this precision))
			expect(3333.0f roundToValueDigits(2, true), is equal to(3400.0f) within(this precision))
			expect(0.3333f roundToValueDigits(2, false), is equal to(0.33f) within(this precision))
			expect(0.3333f roundToValueDigits(2, true), is equal to(0.34f) within(this precision))
		})
		this add("get scientific power string", func {
			expect(3333.0f getScientificPowerString(), is equal to("3.33E3"))
			expect(10000.0f getScientificPowerString(), is equal to("1.00E4"))
			expect(0.0044f getScientificPowerString(), is equal to("4.40E-3"))
		})
	}
}

FloatExtensionTest new() run() . free()
