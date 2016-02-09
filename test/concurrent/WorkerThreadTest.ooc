/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use concurrent
use unit
import threading/Thread

WorkerThreadTest: class extends Fixture {
	threads := static SynchronizedList<ThreadId> new()
	sum: static Long = 0
	taskUp := func {
		This threads add(Thread currentThreadId())
		Time sleepMilli(250)
		This sum += 1
		//">" print(); fflush(stdout)
		Time sleepMilli(250)
		This threads add(Thread currentThreadId())
	}
	taskDown := func {
		This threads add(Thread currentThreadId())
		Time sleepMilli(250)
		This sum -= 1
		//"<" print(); fflush(stdout)
		Time sleepMilli(250)
		This threads add(Thread currentThreadId())
	}
	init: func {
		super("WorkerThread")
		this add("Create and wait for all", func {
			thread := WorkerThread new()
			thread wait(this taskUp)
			expect(this sum, is greater than(0))
			thread add(this taskUp)
			thread add(this taskUp)
			thread add(this taskDown)
			thread add(this taskDown)
			thread add(this taskUp)
			thread add(this taskDown)
			thread add(this taskDown)
			thread wait() . free()
			expect(this sum, is equal to(0))
		})
		this add("Correct threading", func {
			mainThread := Thread currentThreadId()
			for (i in 0 .. This threads count - 1) {
				expect(mainThread != This threads[i])
				expect(This threads[i], is equal to(This threads[i + 1]))
			}
		})
	}
	free: override func {
		(this taskUp as Closure) free()
		(this taskDown as Closure) free()
		this threads free()
		super()
	}
}

WorkerThreadTest new() run() . free()
