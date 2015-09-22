use ooc-base
use ooc-unit
use ooc-math
import math

PromiseTest: class extends Fixture {
	init: func {
		super("Promise")
		this add("constructors", func {
      max := func () -> Int {
          200
      }

      p := Promise<Int> new(max)

			/*t := Text new(c"test string", 5)
			expect(t toString() == "test ")
			t = Text new("string")
			t2 := Text new("str")
			t free()
			expect(t count == 0)
			expect(t isEmpty)*/
		})
	}
}

PromiseTest new() run()
