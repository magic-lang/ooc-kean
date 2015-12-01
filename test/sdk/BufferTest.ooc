use ooc-base
use ooc-unit
use ooc-geometry
import math

BufferTest: class extends Fixture {
	init: func {
		super("Buffer")
		this add("constructor static", func {
			t := Buffer new(c"test" as UInt8*, 4)
			expect(t size, is equal to(4))
		})
		this add("constructor allocate", func {
			t := Buffer new(4)
			expect(t size, is equal to(4))
			expect(t free())
			expect(t pointer == null)
			expect(t size, is equal to(0))
		})
		this add("copy", func {
			t := Buffer new(4)
			p := t pointer
			expect(t size, is equal to(4))
			s := t copy()
			expect(t pointer == p)
			expect(t size, is equal to(4))
			expect(t free())
			expect(t pointer == null)
			expect(t size, is equal to(0))

			expect(s pointer != p)
			expect(s size, is equal to(4))
			expect(s free())
			expect(s pointer == null)
			expect(s size, is equal to(0))
		})
	}
}

BufferTest new() run() . free()
