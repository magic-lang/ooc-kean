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

			resultNone2 := builder toString()
			expect(resultNone == resultNone2)

			resultChar := builder join('x')
			expect(resultChar == "12x34x56x78x90")

			builder add("1234")
			resultLonger := builder join("<")
			expect(resultLonger == "12<34<56<78<90<1234")

			(resultDashes, resultNone, resultNone2, resultChar, resultLonger, builder) free()
		})
		this add("operators", func {
			builder := StringBuilder new()
			builder add("12") . add("34") . add("56") . add("78") . add("90")

			expect(builder[1] == "34")
			builder[1] = "45"
			expect(builder[1] == "45")

			for (i in 1 .. 4)
				builder[i] = "Q"

			result := builder toString()
			expect(result == "12QQQ90")
			(result, builder) free()
		})
		this add("owns memory", func {
			builder := StringBuilder new(5, true)
			temp := "78" + "90"
			builder add("12" + "34") . add("34" + "56") . add(temp)
			builder free()
		})
	}
}

StringBuilderTest new() run() . free()
