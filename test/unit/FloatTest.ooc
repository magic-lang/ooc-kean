/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

FloatTest: class extends Fixture {
	init: func {
		super("Float")
		this add("0.0 is equal to 0.0", func { expect(0.0f, is equal to(0.0f)) })
		this add("1.0 is equal to 1.0", func { expect(1.0f, is equal to(1.0f)) })
		this add("2.0 is equal to 2", func { expect(2.0f, is equal to(2.0f)) })
		this add("9.0 is equal to 9", func { expect(9.0f, is equal to(9.0f)) })
		this add("10.0 is equal to 10", func { expect(10.0f, is equal to(10.0f)) })
		this add("100.0 is equal to 100", func { expect(100.0f, is equal to(100.0f)) })
		this add("-1.0 is equal to -1", func { expect(-1.0f, is equal to(-1.0f)) })
		this add("4.2 is equal to 4.2", func { expect(4.2f, is equal to(4.2f)) })
		this add("-13.37 is equal to -13.37", func { expect(-13.37f, is equal to(-13.37f)) })
		this add("-13.37 is equal to -13.38 within 0.1", func { expect(-13.37f, is equal to(-13.38f) within(0.1f)) })
		this add("-13.37 is not equal to -13.38 within 0.001", func { expect(-13.37f, is notEqual to(-13.38f) within(0.001f)) })
		this add("0.0 is not equal to 4.2", func { expect(0.0f, is notEqual to(4.2f)) })
		this add("0.0 is equal to -0.0", func { expect(0.0f, is equal to(-0.0f)) })
		this add("0.0 is less than 0.00000001", func { expect(0.0f, is less than(0.000001f)) })
		this add("0.0 is greater than -0.00000001", func { expect(0.0f, is greater than(-0.000001f)) })
		this add("7.0 is greater or equal than 7.0", func { expect(7.0f, is greaterOrEqual than(7.0f)) })
		this add("7.0 is less or equal than 7.0", func { expect(7.0f, is lessOrEqual than(7.0f)) })
	}
}

FloatTest new() run() . free()
