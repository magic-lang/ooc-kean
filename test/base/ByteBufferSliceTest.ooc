use ooc-base
use ooc-unit

ByteBufferSliceTest: class extends Fixture {
	init: func {
		super("ByteBufferSlice")

	version(!gc) {
		this add("Int", func {
			yuv := ByteBuffer new(30000)
			y := yuv slice(0, 20000)
			uv := yuv slice(20000, 10000)
			expect(yuv referenceCount _count == 2, is true)
			y referenceCount decrease()
			expect(yuv referenceCount _count == 1, is true)
		})
	}
	}
}
ByteBufferSliceTest new() run()
