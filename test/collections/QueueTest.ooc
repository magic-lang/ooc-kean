use ooc-unit
use ooc-collections

QueueTest: class extends Fixture {
	init: func() {
		super("Queue")
		this add("Queue cover create", func() {

			queue := Queue<Int> new(3)

			expect(queue count, is equal to(0))
			expect(queue isEmpty(), is equal to(true))
			expect(queue isFull(), is equal to(false))
			queue add(0)
			expect(queue isEmpty(), is equal to(false))
			queue add(1)
			queue add(2)

			expect(queue count, is equal to(3))
			expect(queue isFull(), is equal to(true))
			removedInt := queue pop()
			expect(queue count, is equal to(2))
			expect(queue isFull(), is equal to(false))
			expect(removedInt, is equal to(0))
			expect(queue peek(), is equal to(1))
			removedInt = queue pop()
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(1))
			removedInt = queue pop()
			expect(queue count, is equal to(0))
			expect(queue isEmpty(), is equal to(true))
			expect(removedInt, is equal to(2))

			queue add(3)
			expect(queue isEmpty(), is equal to(false))
			queue add(4)
			queue add(5)
			expect(queue count, is equal to(3))
			expect(queue isFull(), is equal to(true))
			removedInt = queue pop()
			expect(queue count, is equal to(2))
			expect(removedInt, is equal to(3))
			expect(queue peek(), is equal to(4))
			removedInt = queue pop()
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(4))
			removedInt = queue pop()
			expect(queue count, is equal to(0))
			expect(queue isEmpty(), is equal to(true))
			expect(removedInt, is equal to(5))

			for (i in 0..queue count)
				queue pop()
			expect(queue count, is equal to(0))

			for (i in 0..10)
				queue add(i)
			expect(queue count, is equal to(3))
			expect(queue isFull(), is equal to(true))
			count := queue count
			for (i in 0..count)
				expect(queue pop(), is equal to(i))
			expect(queue isEmpty(), is equal to(true))

			queue free()
		})
	}
}
QueueTest new() run()
