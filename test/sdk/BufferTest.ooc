use base
use unit
use geometry
import math

BufferTest: class extends Fixture {
	init: func {
		super("Buffer")
		this add("constructor static", func {
			buffer := Buffer new(c"test" as UInt8*, 4)
			expect(buffer size, is equal to(4))
		})
		this add("constructor allocate", func {
			buffer := Buffer new(4)
			expect(buffer size, is equal to(4))
			expect(buffer free())
			expect(buffer pointer == null)
			expect(buffer size, is equal to(0))
		})
		this add("copy", func {
			buffer := Buffer new(4)
			p := buffer pointer
			expect(buffer size, is equal to(4))
			s := buffer copy()
			expect(buffer pointer == p)
			expect(buffer size, is equal to(4))
			expect(buffer free())
			expect(buffer pointer == null)
			expect(buffer size, is equal to(0))

			expect(s pointer != p)
			expect(s size, is equal to(4))
			expect(s free())
			expect(s pointer == null)
			expect(s size, is equal to(0))
		})
		this add("extend", func {
			buffer := Buffer new()
			expect(buffer pointer == null)
			buffer resize(4)
			expect(buffer size, is equal to(4))
			buffer resize(2)
			expect(buffer size, is equal to(2))
			buffer resize(8)
			expect(buffer size, is equal to(8))
			buffer free()
		})
	}
}

BufferTest new() run() . free()
