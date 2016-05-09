/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

IntegerTest: class extends Fixture {
	value: static Int = 0
	init: func {
		super("Integer")
		this add("0 is equal to 0", func { expect(0, is equal to(0)) })
		this add("1 is equal to 1", func { expect(1, is equal to(1)) })
		this add("2 is equal to 2", func { expect(2, is equal to(2)) })
		this add("9 is equal to 9", func { expect(9, is equal to(9)) })
		this add("10 is equal to 10", func { expect(10, is equal to(10)) })
		this add("100 is equal to 100", func { expect(100, is equal to(100)) })
		this add("-1 is equal to -1", func { expect(-1, is equal to(-1)) })
		this add("42 is equal to 42", func { expect(42, is equal to(42)) })
		this add("-1337 is equal to -1337", func { expect(-1337, is equal to(-1337)) })
		this add("0 is not equal to 42", func { expect(0, is notEqual to(1)) })
		this add("0 is equal to -0", func { expect(0, is equal to(-0)) })
		this add("0 is less than 1", func { expect(0, is less than(1)) })
		this add("0.0 is greater than -1", func { expect(0, is greater than(-1)) })

		this add("times", func {
			5 times(This increase)
			expect(This value, is equal to(5))
			6 times(This increaseIndex)
			expect(This value, is equal to(5 + 15))
		})
	}
	increase: static func { This value += 1 }
	increaseIndex: static func (index: Int) { This value += index }
}

IntegerTest new() run() . free()
