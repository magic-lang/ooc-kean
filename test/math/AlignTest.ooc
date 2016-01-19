use math
use ooc-unit

AlignTest: class extends Fixture {
	init: func {
		super("AlignTest")
		this add("align to 64", func {
			result := 720 align(64)
			expect(result, is equal to(768))
		})
		this add("align to 1", func {
			for (i in 0 .. 66)
				expect(i align(1), is equal to(i))
		})
	}
}

AlignTest new() run() . free()
