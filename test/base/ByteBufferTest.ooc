use ooc-base
use ooc-unit

ByteBufferTest: class extends Fixture {
	init: func {
		super("ByteBuffer")
		this add("set data", func {
			buffer := ByteBuffer new(1024)
			expect(buffer size, is equal to(1024))
			expect(buffer referenceCount count, is equal to(1))
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(i))
			buffer free()
		})
		this add("zero", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffer zero()
			for (i in 0 .. 1024 / 8)
				expect(buffer pointer[i] as Int, is equal to(0))
			buffer free()
		})
		this add("copy and copyTo", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			buffercopy := buffer copy()
			buffer free()
			for (i in 0 .. 1024 / 8)
				expect(buffercopy pointer[i] as Int, is equal to(buffer pointer[i] as Int))
			buffercopy free()
		})
		this add("slice", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			slice := buffer slice(10, 8)
			buffer free()
			expect(slice size, is equal to(8))
			expect(slice pointer[0] as Int, is equal to(10))
			slice free()
		})
	}
}

ByteBufferTest new() run()
