/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
