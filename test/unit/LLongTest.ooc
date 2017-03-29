/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

LLongTest: class extends Fixture {
	init: func {
		super("LLong, ULLong")

		this add("1_000_000_000 is equal to 1_000_000_000", func { expect(1_000_000_000LL, is equal to(1_000_000_000LL)) })
		this add("-1_000_000_001 is less than 1_000_000_000", func { expect(-1_000_000_001LL, is less than(-1_000_000_000LL)) })
		this add("100_000_000_000 is greater than 99_999_999_999", func { expect(100_000_000_000LL, is greater than(99_999_999_999LL)) })

		this add("1_000_000_000U is equal to 1_000_000_000U", func { expect(1_000_000_000ULL, is equal to(1_000_000_000ULL)) })
		this add("1_000_000_000U is less than 1_000_000_001U", func { expect(1_000_000_000ULL, is less than(1_000_000_001ULL)) })
		this add("100_000_000_000U is greater than 99_999_999_999U", func { expect(100_000_000_000ULL, is greater than(99_999_999_999ULL)) })
	}
}

LLongTest new() run() . free()
