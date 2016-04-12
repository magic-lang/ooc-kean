/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use base
use concurrent

TestObject: class {
	_isAlive: Bool*
	init: func (=_isAlive) {
		this _isAlive@ = true
	}
	free: override func {
		this _isAlive@ = false
		super()
	}
}

ReferenceCounterTest: class extends Fixture {
	init: func {
		super("ReferenceCounter")
		this add("single thread", func {
			isAlive: Bool
			object := TestObject new(isAlive&)
			expect(isAlive)
			counter := ReferenceCounter new(object)
			for (i in 0 .. 10)
				counter increase()
			for (i in 0 .. 10)
				counter decrease()
			expect(isAlive, is false)
			counter free()
		})
		this add("multiple threads", This _testMultipleThreads)
	}
	_testMultipleThreads: static func {
		isAlive: Bool
		object := TestObject new(isAlive&)
		counter := ReferenceCounter new(object)
		counter isSafe = true
		numberOfThreads := 8
		countPerThread := 500
		threads := Thread[numberOfThreads] new()
		expect(isAlive)
		job := func {
			for (i in 0 .. countPerThread) {
				counter increase()
				Thread yield()
				counter decrease()
				Thread yield()
			}
		}
		counter increase()
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(job)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(isAlive)
		counter decrease()
		expect(isAlive, is false)
		(job as Closure) free()
		(threads, counter) free()
	}
}

ReferenceCounterTest new() run() . free()
