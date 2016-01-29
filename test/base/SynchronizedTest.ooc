/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit
import threading/Thread

TestClass: class {
	data: Int
	init: func { this data = 0 }
	increment: func { this data += 1 }
	decrement: func { this data -= 1 }
}

SynchronizedTest: class extends Fixture {
	value: static Int = 0
	otherValue: static Int = 0
	valueIncrementer := static func { This value += 1 }
	valueDecrementer := static func { This value -= 1 }
	otherValueUp := static func -> Int { This value + 1 }
	otherValueDown := static func -> Int { This value + 1 }

	init: func {
		super("Synchronized")
		this add("two threads", func {
			obj := TestClass new()
			sync := Synchronized new()

			thread1 := Thread new(
				func { for (i in 0 .. 200_000) {
					sync lock()
					obj decrement()
					sync unlock()
					sync lock(This valueDecrementer)
				}
			})
			thread2 := Thread new(
				func { for (i in 0 .. 200_001) {
					sync lock()
					obj increment()
					sync unlock()
					sync lock(This valueIncrementer)
				}
			})
			thread1 start()
			thread2 start()
			thread2 wait()
			thread1 wait()
			expect(obj data, is equal to(1))
			expect(This value, is equal to(1))

			obj free()
			sync free()
			thread1 free()
			thread2 free()
		})
	}
}

SynchronizedTest new() run() . free()
