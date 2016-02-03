/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
import threading/[Thread, Mutex]

MutexTest: class extends Fixture {
	init: func {
		super("Mutex")
		this add("basic", This _testBasicUsage)
	}
	_testBasicUsage: static func {
		threadCount := 4
		countPerThread := 1_000
		mutex := Mutex new()
		value := Cell<Int> new(0)

		increaser := func {
			value set(value get() + 1)
		}

		threads := Thread[threadCount] new()
		job := func {
			for (i in 0 .. countPerThread) {
				mutex lock()
				value set(value get() + 1)
				mutex unlock()
				mutex with(increaser)
				Thread yield()
			}
		}
		for (i in 0 .. threads length) {
			threads[i] = Thread new(job)
			expect(threads[i] start())
		}
		for (i in 0 .. threads length) {
			expect(threads[i] wait())
			threads[i] free()
		}
		threads free()
		mutex free()
		expect(value get(), is equal to(2 * countPerThread * threadCount))
		(job as Closure) free()
		value free()
	}
}

MutexTest new() run() . free()
