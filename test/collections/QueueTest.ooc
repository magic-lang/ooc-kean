use ooc-unit
use ooc-collections

QueueTest: class extends Fixture {
	init: func() {
		super("Queue")
		this add("Queue cover create", func() {

			queue := Queue<Int> new(3)

			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(queue full, is equal to(false))
			queue enqueue(0)
			expect(queue empty, is equal to(false))
			queue enqueue(1)
			queue enqueue(2)

			expect(queue count, is equal to(3))
			expect(queue full, is equal to(true))
			removedInt := queue dequeue()
			expect(queue count, is equal to(2))
			expect(queue full, is equal to(false))
			expect(removedInt, is equal to(0))
			expect(queue peek(), is equal to(1))
			removedInt = queue dequeue()
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(1))
			removedInt = queue dequeue()
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(removedInt, is equal to(2))

			queue enqueue(3)
			expect(queue empty, is equal to(false))
			queue enqueue(4)
			queue enqueue(5)
			expect(queue count, is equal to(3))
			expect(queue full, is equal to(true))
			removedInt = queue dequeue()
			expect(queue count, is equal to(2))
			expect(removedInt, is equal to(3))
			expect(queue peek(), is equal to(4))
			removedInt = queue dequeue()
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(4))
			removedInt = queue dequeue()
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(removedInt, is equal to(5))

			for (i in 0..queue count)
				queue dequeue()
			expect(queue count, is equal to(0))

			for (i in 0..50)
				queue enqueue(i)
			expect(queue count, is equal to(50))
			queue clear()
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			for (i in 0..111)
				queue enqueue(i)
			result := queue dequeue()
			expect(result, is equal to(0))
			expect(queue count, is equal to(110))
			count := queue count
			for (i in 0..count) {
				result := queue dequeue()
				expect(result, is equal to(i + 1))
			}
			queue free()
		})
	}
}
QueueTest new() run()
