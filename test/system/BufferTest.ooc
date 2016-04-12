/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit
use geometry

BufferTest: class extends Fixture {
	init: func {
		super("Buffer")
		this add("constructor static", func {
			buffer := Buffer new(c"test" as Byte*, 4)
			expect(buffer size, is equal to(4))
		})
		this add("constructor allocate", func {
			buffer := Buffer new(4)
			expect(buffer size, is equal to(4))
			expect(buffer free())
			expect(buffer pointer, is Null)
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
			expect(buffer pointer, is Null)
			expect(buffer size, is equal to(0))

			expect(s pointer != p)
			expect(s size, is equal to(4))
			expect(s free())
			expect(s pointer, is Null)
			expect(s size, is equal to(0))
		})
		this add("copyTo, moveTo", func {
			buffer := Buffer new(1024)
			other := Buffer new(1024)
			for (i in 0 .. 1024)
				(buffer pointer as Byte*)[i] = 128 as Byte
			buffer copyTo(other)
			for (i in 0 .. 1024)
				expect((other pointer as Byte*)[i] == 128 as Byte)
			buffer reset(0)
			for (i in 0 .. 1024)
				expect((buffer pointer as Byte*)[i] == 0)
			other moveTo(buffer)
			for (i in 0 .. 1024)
				expect((buffer pointer as Byte*)[i] == 128 as Byte)
			(buffer, other) free()
		})
		this add("extend", func {
			buffer := Buffer new()
			expect(buffer pointer, is Null)
			buffer resize(4)
			expect(buffer size, is equal to(4))
			buffer resize(2)
			expect(buffer size, is equal to(2))
			buffer resize(8)
			expect(buffer size, is equal to(8))
			buffer free()
		})
		this add("slice", func {
			buffer := Buffer new(64)
			for (i in 0 .. 64)
				(buffer pointer as Byte*)[i] = i as Byte
			other := buffer slice(32, 8)
			expect((other pointer as Byte*)[0] == 32 as Byte)
			(buffer pointer as Byte*)[32] = 12 as Byte
			expect((other pointer as Byte*)[0] == 12 as Byte)
			expect(other size, is equal to(8))
			buffer free()
		})
	}
}

BufferTest new() run() . free()
