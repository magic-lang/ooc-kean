/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import mangling
use unit

ExceptionTest: class extends Fixture {
	init: func {
		super("Exception")
		this add("basic", func {
			testCount := 100
			exceptionCount := 0
			for (i in 0 .. testCount)
				try {
					try {
						raise("test exception")
					} catch (exception: Exception) {
						exception free()
						exceptionCount += 1
						raise("another one")
					}
				} catch (exception: Exception) {
					exception free()
					exceptionCount += 1
				}
			expect(exceptionCount, is equal to(2 * testCount))
		})
		this add("empty", func {
			count := 0
			for (i in 0 .. 100)
				try { }
				catch (Exception) { count += 1 }
			expect(count, is equal to(0))
		})
		this add("break from try", func {
			count := 0
			for (i in 0 .. 100)
				try {
					break
				} catch (Exception) { count += 1 }
			expect(count, is equal to(0))
		})
		this add("demangler", func {
			test := "Exception__Exception_throw_impl"
			result := Demangler demangle(test)
			name := result fullName
			expect(name, is equal to("Exception throw_impl"))
			name free()
			(test, result) free()
		})
	}
}

ExceptionTest new() run() . free()
