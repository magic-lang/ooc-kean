/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

EnvTest: class extends Fixture {
	init: func {
		super("Env")
		this add("set, get, unset", func {
			Env set("abc", "def", true)
			result := Env get("abc")
			expect(result, is equal to("def"))
			result free()

			Env set("abc", "efg", true)
			result = Env get("abc")
			expect(result, is equal to("efg"))
			result free()

			Env set("abc", "fgh", false)
			result = Env get("abc")
			expect(result, is equal to("efg"))
			result free()

			Env unset("abc")
			expect(Env get("abc"), is Null)
		})
	}
}

EnvTest new() run() . free()
