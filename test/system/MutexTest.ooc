/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use concurrent

MutexTest: class extends Fixture {
	init: func {
		super("Mutex")
		this add("basic", This _testBasicUsage)
		this add("global", This _testGlobal)
		this add("recursive", This _testRecursive)
	}
	_testBasicUsage: static func {
		threadCount := 4
		countPerThread := 1_000
		mutex := Mutex new()
		value := Cell<Int> new(0)

		increaser := func {
			value set(value get() + 1)
		}
		increaser = ((increaser as Closure) take() as Func)

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
		expect(value get(), is equal to(2 * countPerThread * threadCount))
		(job as Closure) free()
		(threads, mutex, value) free()
	}
	_testGlobal: static func {
		threadCount := 4
		countPerThread := 1_000
		mutexes := Mutex[threadCount] new()
		for (i in 0 .. threadCount)
			mutexes[i] = Mutex new(MutexType Global)

		value := Cell<Int> new(0)

		increaser := func {
			value set(value get() + 1)
		}
		increaser = ((increaser as Closure) take() as Func)

		threads := Thread[threadCount] new()
		job := func (index: Int) {
			for (i in 0 .. countPerThread) {
				mutexes[index] lock()
				value set(value get() + 1)
				mutexes[index] unlock()
				mutexes[index] with(increaser)
				Thread yield()
			}
		}
		for (i in 0 .. threads length) {
			threads[i] = Thread new(|| job(i))
			expect(threads[i] start())
		}
		for (i in 0 .. threads length) {
			expect(threads[i] wait())
			threads[i] free()
		}
		for (i in 0 .. threadCount)
			mutexes[i] free()
		expect(value get(), is equal to(2 * countPerThread * threadCount))
		(job as Closure) free()
		(threads, mutexes, value) free()
	}
	_testRecursive: static func {
		mutex := RecursiveMutex new()
		sum := 0

		job := func {
			mutex lock()
			mutex lock()
			sum += 1
			mutex lock()
			sum += 1
			mutex unlock()
			sum += 1
			mutex unlock()
			sum += 1
			mutex unlock()
		}
		other := Thread new(job)
		mutex lock()
		mutex lock()
		other start()
		mutex lock()
		expect(sum, is equal to(0))
		mutex unlock()
		sum -= 2
		mutex unlock()
		sum -= 1
		expect(sum, is equal to(-3))
		mutex unlock()
		other wait()
		sum -= 1
		expect(sum, is equal to(0))
		other free()
		(job as Closure) free()
	}
}

MutexTest new() run() . free()
