/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use math
use unit

AlignTest: class extends Fixture {
	init: func {
		super("AlignTest")
		this add("align to 64", func {
			result := 720 align(64)
			expect(result, is equal to(768))
		})
		this add("align to 1", func {
			for (i in 0 .. 66)
				expect(i align(1), is equal to(i))
		})
	}
}

AlignTest new() run() . free()
