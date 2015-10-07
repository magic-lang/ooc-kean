use ooc-base
use ooc-collections
use ooc-unit
import threading/Thread

SynchronizedQueueTest: class extends Fixture {
	init: func {
		super("SynchronizedQueue")
		this add("single thread", func {
			count := 10_000
			queue := SynchronizedQueue<Int> new()
			for (i in 0 .. count) {
				queue enqueue(i)
				value: Int
				expect(queue peek(value&))
				expect(value, is equal to(0))
				expect(queue count, is equal to(i + 1))
			}
			expect(queue count, is equal to(count))
			for (i in 0 .. count) {
				value: Int
				expect(queue dequeue(value&))
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
				value := queue dequeue(defaultValue)
				expect(value != defaultValue)
				value free()
			}
			value := queue dequeue(defaultValue)
			expect(value, is equal to(defaultValue))
			defaultValue free()
			queue free()
		})
		this add("multiple threads", This _testMultipleThreads)
		this add("multiple threads (class)", This _testMultipleThreadsWithClass)
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
		(job as Closure) dispose()
		job = func {
			for (i in 0 .. countPerThread) {
				value: Int
				expect(queue dequeue(value&))
				expect(value >= 0 && value < countPerThread)
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
		expect(queue count, is equal to(0))
		(job as Closure) dispose()
		threads free()
		queue free()
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
		(job as Closure) dispose()
		job = func {
			for (i in 0 .. countPerThread) {
				value: Cell<Int>
				expect(queue dequeue(value&))
				expect(value get() >= 0 && value get() < countPerThread)
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
		expect(queue count, is equal to(0))
		(job as Closure) dispose()
		threads free()
		queue free()
	}
}

test := SynchronizedQueueTest new()
test run()
test free()
