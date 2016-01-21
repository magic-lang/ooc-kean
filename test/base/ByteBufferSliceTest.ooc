use base
use unit

ByteBufferSliceTest: class extends Fixture {
	init: func {
		super("ByteBufferSlice")

		this add("Int", func {
			yuv := ByteBuffer new(30000)
			y := yuv slice(0, 20000)
			uv := yuv slice(20000, 10000)
			expect(yuv referenceCount _count, is equal to(2))
			y referenceCount decrease()
			expect(yuv referenceCount _count, is equal to(1))
			uv referenceCount decrease()
			yuv referenceCount decrease()
		})
	}
}

ByteBufferSliceTest new() run() . free()
