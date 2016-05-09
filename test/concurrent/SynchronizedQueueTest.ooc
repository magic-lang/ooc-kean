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

SynchronizedQueueTest: class extends Fixture {
	init: func {
		super("SynchronizedQueue")
		this add("single thread", func {
			count := 10_000
			queue := SynchronizedQueue<Int> new()
			for (i in 0 .. count) {
				queue enqueue(i)
				value: Int
				value = queue peek(Int minimumValue)
				expect(value, is equal to(0))
				expect(queue count, is equal to(i + 1))
			}
			expect(queue count, is equal to(count))
			for (i in 0 .. count) {
				value: Int
				value = queue dequeue(Int minimumValue)
				expect(value, is equal to(i))
			}
			expect(queue count, is equal to(0))
			queue free()
		})
		this add("single thread (class)", func {
			count := 10_000
			queue := SynchronizedQueue<Cell<ULong>> new()
			for (i in 0 .. count) {
				queue enqueue(Cell<ULong> new(i))
				expect(queue count, is equal to(i + 1))
			}
			defaultValue := Cell<ULong> new(count + 1)
			for (i in 0 .. count) {
				value := queue dequeue(null)
				expect(value != defaultValue)
				value free()
			}
			value := queue dequeue(defaultValue)
			expect(value get(), is equal to(defaultValue get()))
			defaultValue free()
			queue free()
		})
		this add("multiple threads", This _testMultipleThreads)
		this add("multiple threads (class)", This _testMultipleThreadsWithClass)
		this add("clear and empty", func {
			queue := SynchronizedQueue<Int> new()
			for (i in 0 .. 10) {
				queue enqueue(i)
				expect(queue count, is equal to(i + 1))
			}
			expect(queue empty, is false)
			queue clear()
			expect(queue empty, is true)
			queue free()
		})
	}
	_testMultipleThreads: static func {
		numberOfThreads := 8
		countPerThread := 10_000
		queue := SynchronizedQueue<Int> new()
		threads := Thread[numberOfThreads] new()
		job := func {
			for (i in 0 .. countPerThread)
				queue enqueue(i)
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(job)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(queue count, is equal to(numberOfThreads * countPerThread))
		(job as Closure) free()

		validResult := true
		globalMutex := Mutex new(MutexType Global)
		job = func {
			for (i in 0 .. countPerThread) {
				value := queue dequeue(Int minimumValue)
				if (value < 0 || value >= countPerThread)
					globalMutex with(|| validResult = false)
			}
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(job)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(validResult, is true)
		expect(queue count, is equal to(0))
		(job as Closure) free()
		(threads, queue, globalMutex) free()
	}
	_testMultipleThreadsWithClass: static func {
		numberOfThreads := 8
		countPerThread := 10_000
		queue := SynchronizedQueue<Cell<Int>> new()
		threads := Thread[numberOfThreads] new()
		job := func {
			for (i in 0 .. countPerThread)
				queue enqueue(Cell<Int> new(i))
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(job)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(queue count, is equal to(numberOfThreads * countPerThread))
		(job as Closure) free()

		validResult := true
		globalMutex := Mutex new(MutexType Global)
		job = func {
			for (i in 0 .. countPerThread) {
				value: Cell<Int>
				value = queue dequeue(null)
				if (value get() < 0 || value get() >= countPerThread)
					globalMutex with(|| validResult = false)
				value free()
			}
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(job)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads) {
			threads[i] wait()
			threads[i] free()
		}
		expect(validResult, is true)
		expect(queue count, is equal to(0))
		(job as Closure) free()
		(threads, queue, globalMutex) free()
	}
}

SynchronizedQueueTest new() run() . free()
