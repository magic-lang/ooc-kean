use ooc-unit
use ooc-base
use ooc-collections

VectorQueueTest: class extends Fixture {
	init: func {
		super("VectorQueue")
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

			for (i in 0 .. queue count)
				queue dequeue(removedInt&)
			expect(queue count, is equal to(0))
			for (i in 0 .. 50)
				queue enqueue(i)
			expect(queue count, is equal to(50))
			queue clear()
			expect(queue count, is equal to(0))
			expect(queue empty, is equal to(true))
			for (i in 0 .. 111)
				queue enqueue(i)
			success = queue dequeue(removedInt&)
			expect(removedInt, is equal to(0))
			expect(queue count, is equal to(110))
			count := queue count
			for (i in 0 .. count) {
				success = queue dequeue(removedInt&)
				expect(removedInt, is equal to(i + 1))
			}
			success = queue dequeue(removedInt&)
			expect(success, is equal to(false))
			queue enqueue(666)
			success = queue dequeue(removedInt&)
			expect(success, is equal to(true))
			expect(removedInt, is equal to(666))
			version(debugTests) {
				queueString := queue toString()
				queueString println()
				queueString free()
			}
			queue free()
		})
		this add("Queue positive indexing", func {
			queue := this _createQueue(10, 5)
			version(debugTests)
				for (i in 0 .. queue count)
					(i toString() + " -> " + queue[i] toString()) println()
			for (i in 0 .. 5)
				expect(queue[i], is equal to(i))
			queue free()
		})
		this add("Queue negative indexing", func {
			queue := this _createQueue(10, 5)
			version(debugTests)
				for (i in 1 .. queue count + 1)
					((-i) toString() + " -> " + queue[-i] toString()) println()
			for (i in 1 .. 6)
				expect(queue[-i], is equal to(5 - i))
			queue free()
		})
		this add("Queue wrap positive indexing", func {
			queue := this _createQueue(10, 10, 5)
			version(debugTests)
				for (i in 0 .. queue count)
					(i toString() + " -> " + queue[i] toString()) println()
			for (i in 0 .. 10)
				expect(queue[i], is equal to(5 + i))
			queue free()
		})
		this add("Queue wrap negative indexing", func {
			queue := this _createQueue(10, 10, 5)
			version(debugTests)
				for (i in 1 .. queue count + 1)
					((-i) toString() + " -> " + queue[-i] toString()) println()
			for (i in 1 .. 11)
				expect(queue[-i], is equal to(15 - i))
			queue free()
		})
	}
	_createQueue: func (capacity, fill: Int, replace := 0) -> VectorQueue<Int> {
		result := VectorQueue<Int> new(capacity)
		for (i in 0 .. fill)
			result enqueue(i)
		dummy: Int
		for (i in 0 .. replace)
			result dequeue(dummy&)
		for (i in 0 .. replace)
			result enqueue(fill + i)
		result
	}
}
VectorQueueTest new() run()
