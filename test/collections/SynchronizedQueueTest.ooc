use ooc-base
use ooc-collections
use ooc-unit
import os/Time

SynchronizedQueueTest: class extends Fixture {
	init: func {
		queue := SynchronizedQueue<Int> new()

		func1 := func { queue enqueue(123) }
		func2 := func {
			result: Int
			success := queue peek(result&)
			expect(success)
			expect(result == 123)
		}
		func3 := func {
			result: Int
			success := queue dequeue(result&)
			if (success)
				expect(result == 123)
			else
				expect(queue empty)
		}
		func4 := func {
			result: Int
			success := queue peek(result&)
			expect(!success)
			expect(queue empty)
		}

		super("SynchronizedQueue")
		this add("SynchronizedQueue cover create", func {
			expect(queue empty)
			expect(queue count, is equal to(0))

			pool := ThreadPool new(3)
			promises := Promise[100+200+200+20] new()
			/* Enqueue values asynchronously */
			for (i in 0 .. 100)
				promises[i] = pool getPromise(func1)

			/* Peek values asynchronously */
			for (i in 0 .. 200)
				promises[100+i] = pool getPromise(func2)

			/* Dequeue values asynchronously */
			for (i in 0 .. 200)
				promises[100+200+i] = pool getPromise(func3)

			/* Peek values asynchronously in empty Queue */
			for (i in 0 .. 20)
				promises[100+200+20+i] = pool getPromise(func4)

			for (i in 0 .. 100+200+200) {
				promises[i] wait()
			}

			expect(queue empty)
			expect(queue count, is equal to(0))

			queue free()
			pool free()
		})
	}
}

SynchronizedQueueTest new() run()
