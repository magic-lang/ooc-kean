/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent
use unit

AtomicTest: class extends Fixture {
	_value := static AtomicInt new(0)
	init: func {
		super("Atomic")
		this add("read write", This _testReadWrite)
		this add("multithreaded swap", This _testSwap)
		this add("bool", func {
			value := AtomicBool new(true)
			expect(value get(), is true)
			value set(false)
			expect(value get(), is false)
			value or(true)
			expect(value get(), is true)
			value and(false)
			expect(value get(), is false)
			value xor(true)
			expect(value get(), is true)
		})
	}
	_testReadWrite: static func {
		expect(_value get(), is equal to(0))
		_value set(13)
		expect(_value get(), is equal to(13))
		_value subtract(2)
		expect(_value get(), is equal to(11))
		expect(_value swap(0), is equal to(11))
		expect(_value get(), is equal to(0))
		range := 10000
		numberOfThreads := 7
		job := func {
			for (_ in 0 .. range)
				_value add(1)
		}
		threads: Thread[numberOfThreads]
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job)
		for (i in 0 .. numberOfThreads)
			threads[i] start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(_value get(), is equal to(range * numberOfThreads))
		(job as Closure) free()
	}
	_testSwap: static func {
		callCount := Cell<Int> new()
		numberOfThreads := 6
		_value set(0)
		job := func {
			if (_value swap(1) == 0)
				callCount set(callCount get() + 1)
		}
		threads: Thread[numberOfThreads]
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job)
		for (i in 0 .. numberOfThreads)
			threads[i] start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(callCount get(), is equal to(1))
		(job as Closure, callCount) free()
	}
}

AtomicTest new() run() . free()
