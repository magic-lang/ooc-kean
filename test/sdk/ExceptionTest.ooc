use ooc-unit

ExceptionTest: class extends Fixture {
	init: func {
		super("Exception")
		this add("basic", func {
			testCount := 100
			exceptionCount := 0
			for (i in 0 .. testCount)
				try {
					try {
						raise("test exception")
					} catch (exception: Exception) {
						exception free()
						++exceptionCount
						raise("another one")
					}
				} catch (exception: Exception) {
					exception free()
					++exceptionCount
				}
			expect(exceptionCount, is equal to(2 * testCount))
		})
		this add("empty", func {
			for (i in 0 .. 100)
				try { }
				catch (exception: Exception) { }
		})
		this add("break from try", func {
			for (i in 0 .. 100)
				try {
					break
				} catch (exception: Exception) { }
		})
	}
}

ExceptionTest new() run() . free()
