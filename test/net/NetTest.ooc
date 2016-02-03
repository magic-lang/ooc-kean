/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use net

//TODO: Write actual tests for source/net
// Right now, this is just to make sure that the code is processed and compiled when testing
NetTest: class extends Fixture {
	init: func {
		super("Net")
		this add("No test", func {
			expect(true)
		})
	}
}

NetTest new() run() . free()
