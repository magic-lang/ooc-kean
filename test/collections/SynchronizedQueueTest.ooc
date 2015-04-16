use ooc-base
use ooc-collections
use ooc-unit

SynchronizedQueueTest: class extends Fixture {

	init: func() {
		queue := SynchronizedQueue<Int> new(3)

		func1 := func {
			queue enqueue(0)
			queue enqueue(1)
		}
		func2 := func {
			queue wait()
			result := queue dequeue()
			expect(result == 0 || result == 1)
		}
		func3 := func {
			queue wait()
			result := queue dequeue()
			expect(result == 0 || result == 1)
		}

		super("SynchronizedQueue")
		this add("SynchronizedQueue cover create", func() {
			expect(queue empty)
			expect(queue count, is equal to(0))
			expect(queue full, is equal to(false))

			pool := ThreadPool new(3)
			pool add(func1)
			pool add(func2)
			pool add(func3)

			pool waitAll()

			expect(queue empty)
			expect(queue count, is equal to(0))
			expect(queue full, is equal to(false))

			queue free()
		})
	}
}

SynchronizedQueueTest new() run()
