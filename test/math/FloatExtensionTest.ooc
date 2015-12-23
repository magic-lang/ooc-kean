use ooc-unit
use ooc-math

FloatExtensionTest: class extends Fixture {
	precision := 1.0e-5f
	init: func {
		super("FloatExtension")
		this add("decompose to coefficient and radix", func {
			(coefficient, radix) := Float decomposeToCoefficientAndRadix(3333.0f, 2)
			expect(coefficient, is equal to(33.33f) within(this precision))
			expect(radix, is equal to(100.0f) within(this precision))
			(coefficient, radix) = Float decomposeToCoefficientAndRadix(0.3333f, 2)
			expect(coefficient, is equal to(33.33f) within(this precision))
			expect(radix, is equal to(0.01f) within(this precision))
		})
		this add("round to value digits", func {
			expect(Float roundToValueDigits(3333.0f, 2, false), is equal to(3300.0f) within(this precision))
			expect(Float roundToValueDigits(3333.0f, 2, true), is equal to(3400.0f) within(this precision))
			expect(Float roundToValueDigits(0.3333f, 2, false), is equal to(0.33f) within(this precision))
			expect(Float roundToValueDigits(0.3333f, 2, true), is equal to(0.34f) within(this precision))
		})
		this add("get scientific power string", func {
			expect(Float getScientificPowerString(3333.0f), is equal to("3.33E3"))
			expect(Float getScientificPowerString(10000.0f), is equal to("1.00E4"))
			expect(Float getScientificPowerString(0.0044f), is equal to("4.40E-3"))
		})
	}
}

FloatExtensionTest new() run() . free()
