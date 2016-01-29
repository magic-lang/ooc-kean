/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

// TODO: Skipping the variable and having "is not equal to" inside an expect call does not work
StringTest: class extends Fixture {
	init: func {
		super("String")
		isNull := is Null
		this add("null is null", func { expect(null, isNull) })
		this add("empty is not null", func { expect("", is not Null) })

		this add("empty is empty", func { expect("", is empty) })
		this add("code is not empty", func { expect("code", is not empty) })

		this add("code is equal to code", func { expect("code", is equal to("code")) })
		isNotEqualToNerd := is not equal to("nerd")
		this add("code is not equal to nerd", func { expect("code", isNotEqualToNerd) })
		isNotEqualToNull := is not equal to(null)
		this add("code is not equal to null", func { expect("code", isNotEqualToNull) })
		isNotEqualToEmpty := is not equal to("")
		this add("code is not equal to empty", func { expect("code", isNotEqualToEmpty) })
		isNotEqualToCode := is not equal to("code")
		this add("null is not equal to code", func { expect(null, isNotEqualToCode) })
		isNotEqualToCode2 := is not equal to("code")
		this add("empty is not equal to code", func { expect("", isNotEqualToCode2) })
	}
}

StringTest new() run() . free()
