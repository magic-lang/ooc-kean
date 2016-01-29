/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

DoubleTest: class extends Fixture {
	init: func {
		super("Double")
		this add("0.0 is equal to 0.0", func { expect(0.0, is equal to(0.0)) })
		this add("1.0 is equal to 1.0", func { expect(1.0, is equal to(1.0)) })
		this add("2.0 is equal to 2", func { expect(2.0, is equal to(2.0)) })
		this add("9.0 is equal to 9", func { expect(9.0, is equal to(9.0)) })
		this add("10.0 is equal to 10", func { expect(10.0, is equal to(10.0)) })
		this add("100.0 is equal to 100", func { expect(100.0, is equal to(100.0)) })
		this add("-1.0 is equal to -1", func { expect(-1.0, is equal to(-1.0)) })
		this add("4.2 is equal to 4.2", func { expect(4.2, is equal to(4.2)) })
		this add("-13.37 is equal to -13.37", func { expect(-13.37, is equal to(-13.37)) })
		this add("-13.37 is equal to -13.38 within 0.1", func { expect(-13.37, is equal to(-13.38) within(0.1)) })
		isNotEqualTo1338 := is not equal to(-13.38)
		this add("-13.37 is not equal to -13.38 within 0.001", func { expect(-13.37, isNotEqualTo1338 within(0.001)) })
		isNotEqualTo42 := is not equal to(4.2)
		this add("0.0 is not equal to 4.2", func { expect(0.0, isNotEqualTo42) })
		this add("0.0 is equal to -0.0", func { expect(0.0, is equal to(-0.0)) })
		this add("0.0 is less than 0.00000001", func { expect(0.0, is less than(0.00000001)) })
		this add("0.0 is greater than -0.00000001", func { expect(0.0, is greater than(-0.00000001)) })
	}
}

DoubleTest new() run() . free()
