use ooc-base
use ooc-unit

ByteBufferSliceTest: class extends Fixture {
	init: func {
		super("ByteBufferSlice")

		this add("Int", func {
			yuv := ByteBuffer new(30000)
			y := ByteBufferSlice new(yuv, 0, 20000)
			uv := ByteBufferSlice new(yuv, 20000, 10000)
			expect(yuv _referenceCount _count == 2, is true)
			y decreaseReferenceCount()
			expect(yuv _referenceCount _count == 1, is true)
		})

	}
}
ByteBufferSliceTest new() run()

