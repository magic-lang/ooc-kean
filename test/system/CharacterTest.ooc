/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

CharacterTest: class extends Fixture {
	init: func {
		super("Character")
		this add("basic test", func {
			(a, b, c, d, e) := ('7', 't', 'F', ' ', '9')
			expect(a digit(), is true)
			expect(b digit(), is false)
			expect(b lower(), is true)
			expect(c lower(), is false)
			expect(d whitespace(), is true)
			expect(e alpha(), is false)
			expect(e alphaNumeric(), is true)
			expect(a toInt(), is equal to(e toInt() - 2))
		})
		this add("containedIn", func {
			(a, b, c) := ('x', 'X', '?')
			first := "xylophone?"
			second := "XYLOPHONE!"
			expect(a containedIn(first))
			expect(!b containedIn(first))
			expect(c containedIn(first))
			expect(!a containedIn(second))
			expect(b containedIn(second))
			expect(!c containedIn(second))
		})
	}
}

CharacterTest new() run() . free()
