/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit

StringBuilderTest: class extends Fixture {
	init: func {
		super("StringBuilder")
		this add("basic use", func {
			builder := StringBuilder new()
			builder add("12") . add("34") . add("56") . add("78") . add("90")
			resultDashes := builder join("-")
			expect(resultDashes == "12-34-56-78-90")

			resultNone := builder join("")
			expect(resultNone == "1234567890")

			resultChar := builder join('x')
			expect(resultChar == "12x34x56x78x90")

			builder add("1234")
			resultLonger := builder join("<")
			expect(resultLonger == "12<34<56<78<90<1234")

			(resultDashes, resultNone, resultChar, resultLonger, builder) free()
		})
	}
}

StringBuilderTest new() run() . free()
