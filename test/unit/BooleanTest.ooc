/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

// TODO: Skipping the variable and having "is not equal to" inside an expect call does not work
BooleanTest: class extends Fixture {
	init: func {
		super("Boolean")
		this add("true is true", func { expect(true, is true) })
		this add("false is false", func { expect(false, is false) })

		this add("true", func { expect(true) })

		this add("false is not true", func { expect(false, is notEqual to(true)) })
		this add("true is not false", func { expect(true, is notEqual to(false)) })

		this add("true is equal to true", func { expect(true, is equal to(true)) })
		this add("false is equal to false", func { expect(false, is equal to(false)) })
	}
}

BooleanTest new() run() . free()
