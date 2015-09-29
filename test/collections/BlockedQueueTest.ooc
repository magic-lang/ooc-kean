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
			limitA := 100
			limitB := 200
			limitC := 200
			limitD := 20
			limitE := 4
			limitF := 4
			promises := PromiseCollector new()

			/* Enqueue values asynchronously */
			for (i in 0 .. limitA)
				promises += pool getPromise(func1)

			/* Peek values asynchronously */
			for (i in 0 .. limitB)
				promises += pool getPromise(func2)

			/* Dequeue values asynchronously */
			for (i in 0 .. limitC)
				promises += pool getPromise(func3)

			/* Peek values asynchronously in empty Queue */
			for (i in 0 .. limitD)
				promises += pool getPromise(func4)

			promises wait()

			expect(queue empty)
			expect(queue count, is equal to(0))

			for (i in 0 .. 4) {
				promises += pool getPromise(func5)
				Time sleepMilli(10)
			}
			for (i in 0 .. 4) {
				promises += pool getPromise(func1)
				Time sleepMilli(10)
			}

			promises wait()

			expect(queue empty)

			promises free()
			queue free()
			pool free()
		})
	}
}

BlockedQueueTest new() run()
