use ooc-math
use ooc-unit
import math

AlignTest: class extends Fixture {
	init: func {
		super("AlignTest")
		this add("align to 64", func {
			result := Int align(720, 64)
			expect(result, is equal to(768))
		})
		this add("align to 1", func {
			for (i in 0 .. 66)
				expect(Int align(i, 1), is equal to(i))
		})
	}
}

AlignTest new() run()
