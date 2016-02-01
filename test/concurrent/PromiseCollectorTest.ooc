/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use concurrent
use unit

PromiseCollectorTest: class extends Fixture {
	init: func {
		super("PromiseCollector")
		this add("simple (+ operator)", func {
			promise := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promise2 := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promise3 := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promise4 := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promises := promise + promise2 + promise3 + promise4
			expect(promises wait())
			promises free()
		})
		this add("advanced (+= operator)", func {
			promises := PromiseCollector new()

			for (j in 0 .. 5)
				promises += Promise start(func { for (i in 0 .. 10_000_000) { } })

			extra := Promise start(func { for (i in 0 .. 10_000_000) { } })
			extra cancel()
			promises += extra

			others := PromiseCollector new()
			for (j in 0 .. 5)
				others += Promise start(func { for (i in 0 .. 10_000_000) { } })
			promises += others

			expect(others wait())
			expect(!promises wait())

			promises free()
		})
		this add("clear old promises", func {
			promise := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promise cancel()
			promise2 := Promise start(func { for (i in 0 .. 10_000_000) { } })
			promises := promise + promise2
			expect(promises count, is equal to(2))
			expect(!promises wait())
			promises clear()
			expect(promises count, is equal to(0))
			promises += Promise start(func { for (i in 0 .. 10_000_000) { } })
			promises += Promise start(func { for (i in 0 .. 10_000_000) { } })
			expect(promises wait())
			promises clear()
		})
		this add("wait with timeout", func {
			promises := PromiseCollector new()
			for (j in 0 .. 5)
				promises += Promise start(func { for (i in 0 .. 50_000_000) { } })
			expect(promises wait(0.01), is false)
			expect(promises wait(), is true)
			promises free()
		})
	}
}

PromiseCollectorTest new() run() . free()
