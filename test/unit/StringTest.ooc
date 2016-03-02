/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

StringTest: class extends Fixture {
	init: func {
		super("String")
		this add("null is null", func { expect(null, is Null) })
		this add("empty is not null", func { expect("", is notNull) })
		this add("code is equal to code", func { expect("code", is equal to("code")) })
		this add("code is not equal to nerd", func { expect("code", is notEqual to("nerd")) })
		this add("code is not equal to null", func { expect("code", is notEqual to(null)) })
		this add("code is not equal to empty", func { expect("code", is notEqual to("")) })
		this add("null is not equal to code", func { expect(null, is notEqual to("code")) })
		this add("empty is not equal to code", func { expect("", is notEqual to("code")) })
	}
}

StringTest new() run() . free()
