use ooc-base
use ooc-unit
use ooc-geometry
import math

PointerTest: class extends Fixture {
	init: func {
		super("Pointer")
		this add("allocate & free", func {
			p := Pointer allocate(32)
			expect(p != null)
			expect(p free())
		})
	}
}

PointerTest new() run() . free()
