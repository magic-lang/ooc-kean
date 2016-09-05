/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

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
			for (i in 0 .. 1024 / 8)
				expect(buffercopy pointer[i] as Int, is equal to(buffer pointer[i] as Int))
			buffer free()
			buffercopy free()
		})
		this add("slice", func {
			buffer := ByteBuffer new(1024)
			for (i in 0 .. 1024 / 8)
				buffer pointer[i] = i
			slice := buffer slice(10, 8)
			expect(slice size, is equal to(8))
			expect(slice pointer[0] as Int, is equal to(10))
			slice referenceCount decrease()
		})
		this add("slice 2", func {
			yuv := ByteBuffer new(30000)
			y := yuv slice(0, 20000)
			uv := yuv slice(20000, 10000)
			expect(yuv referenceCount count, is equal to(2))
			y referenceCount decrease()
			expect(yuv referenceCount count, is equal to(1))
			uv referenceCount decrease()
		})
		this add("memset", func {
			buffer := ByteBuffer new(64)
			for (i in 0 .. 64)
				buffer pointer[i] = i
			buffer memset(35)
			for (i in 0 .. 64)
				expect(buffer pointer[i] as Int, is equal to(35))
			buffer referenceCount decrease()
		})
		this add("memset range", func {
			buffer := ByteBuffer new(64)
			for (i in 0 .. 64)
				buffer pointer[i] = i
			buffer memset(1, 62, 35)
			expect(buffer pointer[0] as Int, is equal to(0))
			for (i in 1 .. 63)
				expect(buffer pointer[i] as Int, is equal to(35))
			expect(buffer pointer[63] as Int, is equal to(63))
			buffer referenceCount decrease()
		})
	}
}

ByteBufferTest new() run() . free()
