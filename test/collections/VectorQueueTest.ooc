use ooc-unit
use ooc-base
use ooc-collections

TestClass: class {
	init: func
}

VectorQueueTest: class extends Fixture {
	init: func() {
		super("Queue")
		this add("Queue cover create", func {
			queue := VectorQueue<Int> new(3)

			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(queue full, is equal to(false))
			queue enqueue(0)
			expect(queue empty, is equal to(false))
			queue enqueue(1)
			queue enqueue(2)

			expect(queue count, is equal to(3))
			expect(queue full, is equal to(true))
			removedInt: Int
			success := queue dequeue(removedInt&)
			expect(queue count, is equal to(2))
			expect(queue full, is equal to(false))
			expect(removedInt, is equal to(0))
			expect(success, is equal to(true))
			peekedInt: Int
			success = queue peek(peekedInt&)
			expect(peekedInt, is equal to(1))
			success = queue dequeue(removedInt&)
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(1))
			success = queue dequeue(removedInt&)
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(removedInt, is equal to(2))

			queue enqueue(3)
			expect(queue empty, is equal to(false))
			queue enqueue(4)
			queue enqueue(5)
			expect(queue count, is equal to(3))
			expect(queue full, is equal to(true))
			success = queue dequeue(removedInt&)
			expect(queue count, is equal to(2))
			expect(removedInt, is equal to(3))
			success = queue peek(peekedInt&)
			expect(peekedInt, is equal to(4))
			success = queue dequeue(removedInt&)
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(4))
			success = queue dequeue(removedInt&)
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			expect(removedInt, is equal to(5))

			for (i in 0..queue count)
				queue dequeue(removedInt&)
			expect(queue count, is equal to(0))
			for (i in 0..50)
				queue enqueue(i)
			expect(queue count, is equal to(50))
			queue clear()
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			for (i in 0..111)
				queue enqueue(i)
			success = queue dequeue(removedInt&)
			expect(removedInt, is equal to(0))
			expect(queue count, is equal to(110))
			count := queue count
			for (i in 0..count) {
				success = queue dequeue(removedInt&)
				expect(removedInt, is equal to(i + 1))
			}
			success = queue dequeue(removedInt&)
			expect(success, is equal to(false))
			queue enqueue(666)
			success = queue dequeue(removedInt&)
			expect(success, is equal to(true))
			expect(removedInt, is equal to(666))
			queueString := queue toString()
			queueString println()
			queueString free()
			queue free()
		})
	}
}
VectorQueueTest new() run()
