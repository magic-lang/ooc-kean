use base
use ooc-unit

ByteBufferTest: class extends Fixture {
	init: func {
		super("ByteBuffer")
		this add("set data", func {
			buffer := ByteBuffer new(1024)
			expect(buffer size, is equal to(1024))
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(i))
			buffer referenceCount decrease()
		})
		this add("zero", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffer zero()
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(0))
			buffer referenceCount decrease()
		})
		this add("copy and copyTo", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffercopy := buffer copy()
			buffer free()
			for (i in 0 .. 1024 / 8)
				expect(buffercopy pointer[i] as Int, is equal to(buffer pointer[i] as Int))
			buffercopy referenceCount decrease()
		})
		this add("slice", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			slice := buffer slice(10, 8)
			buffer referenceCount decrease()
			expect(slice size, is equal to(8))
			expect(slice pointer[0] as Int, is equal to(10))
			slice referenceCount decrease()
		})
	}
}

ByteBufferTest new() run() . free()
