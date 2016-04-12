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

BlockedQueueTest: class extends Fixture {
	init: func {
		super("BlockedQueue")
		this add("cover", This _testWithCover)
		this add("class", This _testWithClass)
	}
	_testWithCover: static func {
		queue := BlockedQueue<Int> new()
		numberOfThreads := 4
		countPerThread := 20_000
		totalCount := numberOfThreads * countPerThread
		validResult := true
		globalMutex := Mutex new(MutexType Global)
		produce := func {
			for (i in 1 .. totalCount + 1) {
				queue enqueue(i)
				Thread yield()
			}
		}
		consume := func {
			for (i in 0 .. countPerThread) {
				value := queue wait()
				if (value < 0 || value >= totalCount)
					globalMutex with(|| validResult = false)
			}
		}
		queue enqueue(1)
		threads := Thread[numberOfThreads] new()
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(consume)
			threads[i] start()
		}
		producer := Thread new(produce)
		producer start()
		producer wait()
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(validResult, is true)
		expect(queue count, is equal to(1))
		queue clear()
		expect(queue count, is equal to(0))
		(producer, threads, queue, globalMutex) free()
		(produce as Closure) free()
		(consume as Closure) free()
	}
	_testWithClass: static func {
		queue := BlockedQueue<Cell<Int>> new()
		numberOfThreads := 4
		countPerThread := 20_000
		totalCount := numberOfThreads * countPerThread
		produce := func {
			for (i in 0 .. countPerThread) {
				queue enqueue(Cell<Int> new(i))
				Thread yield()
			}
		}
		consume := func {
			for (i in 0 .. totalCount) {
				value := queue wait()
				expect(value get(), is less than(totalCount))
				value free()
			}
		}
		consumer := Thread new(consume)
		consumer start()
		threads := Thread[numberOfThreads] new()
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(produce)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		consumer wait()
		expect(queue count, is equal to(0))
		(consumer, threads, queue) free()
		(produce as Closure) free()
		(consume as Closure) free()
	}
}

BlockedQueueTest new() run() . free()
