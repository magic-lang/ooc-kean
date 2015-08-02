use ooc-base
use ooc-collections
use ooc-unit
import os/Time

BlockedQueueTest: class extends Fixture {

	init: func {
		queue := BlockedQueue<Int> new()

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
		func5 := func {
			result := queue wait()
			expect(result == 123)
		}

		super("BlockedQueue")
		this add("BlockedQueue cover create", func {
			expect(queue empty)
			expect(queue count, is equal to(0))

			pool := ThreadPool new(8)
			/* Enqueue values asynchronously */
			for (i in 0 .. 100)
				pool add(func1)

			/* Peek values asynchronously */
			for (i in 0 .. 200)
				pool add(func2)

			/* Dequeue values asynchronously */
			for (i in 0 .. 200)
				pool add(func3)

			/* Peek values asynchronously in empty Queue */
			for (i in 0 .. 20)
				pool add(func4)

			pool waitAll()

			expect(queue empty)
			expect(queue count, is equal to(0))

			for (i in 0 .. 4) {
				pool add(func5)
				Time sleepMilli(10)
			}
			for (i in 0 .. 4) {
				pool add(func1)
				Time sleepMilli(10)
			}
			pool waitAll()
			expect(queue empty)

			queue free()
			pool free()
		})
	}
}

BlockedQueueTest new() run()
