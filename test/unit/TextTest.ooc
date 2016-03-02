/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

TextTest: class extends Fixture {
	init: func {
		super("Text")
		this add("Text is equal to Text", func {
			text1 := Text new(c"abc", 3)
			text2 := Text new(c"abc", 3)
			expect(text1, is equal to(text2))
			text1 free(); text2 free()
		})
		this add("Text1 is not equal to Text2", func {
			text1 := Text new(c"abc", 3)
			expect(text1, is notEqual to(Text new(c"cba", 3)))
			text1 free()
		})
	}
}

TextTest new() run() . free()
