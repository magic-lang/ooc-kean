/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

SystemTest: class extends Fixture {
	init: func {
		super("System")
		this add("numProcessors, hostname", func {
			processors := System numProcessors()
			hostname := System hostname()

			expect(processors, is greaterOrEqual than(1))
			expect(hostname, is notNull)

			hostname free()
		})
	}
}

SystemTest new() run() . free()
