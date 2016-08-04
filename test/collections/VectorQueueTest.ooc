/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use collections

MyCover: cover {
	content: Int
	init: func@ (=content)
	init: func@ ~default { this init(0) }
	increase: func { this content += 1 }
}
MyClass: class {
	content: Int
	init: func (=content)
	init: func ~default { this init(0) }
	increase: func { this content += 1 }
}

VectorQueueTest: class extends Fixture {
	init: func {
		super("VectorQueue")
		this add("Queue cover create", func {
			queue := VectorQueue<Int> new(3)

			expect(queue count, is equal to(0))
			expect(queue empty, is true)
			expect(queue isFull, is false)
			queue enqueue(0)
			expect(queue empty, is false)
			queue enqueue(1)
			queue enqueue(2)
			expect(queue count, is equal to(3))
			expect(queue isFull, is true)
			removedInt := queue dequeue(Int minimumValue)
			expect(queue count, is equal to(2))
			expect(queue isFull, is false)
			expect(removedInt, is equal to(0))
			peekedInt: Int
			peekedInt = queue peek(Int minimumValue)
			expect(peekedInt, is equal to(1))
			removedInt = queue dequeue(Int minimumValue)
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(1))
			removedInt = queue dequeue(Int minimumValue)
			expect(queue count, is equal to(0))
			expect(queue empty, is true)
			expect(removedInt, is equal to(2))

			queue enqueue(3)
			expect(queue empty, is false)
			queue enqueue(4)
			queue enqueue(5)
			expect(queue count, is equal to(3))
			expect(queue isFull, is true)
			removedInt = queue dequeue(Int minimumValue)
			expect(queue count, is equal to(2))
			expect(removedInt, is equal to(3))
			peekedInt = queue peek(Int minimumValue)
			expect(peekedInt, is equal to(4))
			removedInt = queue dequeue(Int minimumValue)
			expect(queue count, is equal to(1))
			expect(removedInt, is equal to(4))
			removedInt = queue dequeue(Int minimumValue)
			expect(queue count, is equal to(0))
			expect(queue empty, is true)
			expect(removedInt, is equal to(5))

			for (i in 0 .. queue count)
				queue dequeue(Int minimumValue)
			expect(queue count, is equal to(0))
			for (i in 0 .. 50)
				queue enqueue(i)
			expect(queue count, is equal to(50))
			queue clear()
			expect(queue count, is equal to(0))
			expect(queue empty, is true)
			for (i in 0 .. 111)
				queue enqueue(i)
			removedInt = queue dequeue(Int minimumValue)
			expect(removedInt, is equal to(0))
			expect(queue count, is equal to(110))
			count := queue count
			for (i in 0 .. count) {
				removedInt = queue dequeue(Int minimumValue)
				expect(removedInt, is equal to(i + 1))
			}
			removedInt = queue dequeue(Int minimumValue)
			queue enqueue(666)
			removedInt = queue dequeue(Int minimumValue)
			expect(removedInt, is equal to(666))
			queue free()
		})
		this add("Queue positive indexing", func {
			queue := this _createQueue(10, 5)
			for (i in 0 .. 5) {
				expect(queue[i], is equal to(i))
				queue[i] = i + 1
				expect(queue[i], is equal to(i + 1))
			}
			queue free()
		})
		this add("Queue negative indexing", func {
			queue := this _createQueue(10, 5)
			for (i in 1 .. 6)
				expect(queue[-i], is equal to(5 - i))
			queue free()
		})
		this add("Queue wrap positive indexing", func {
			queue := this _createQueue(10, 10, 5)
			for (i in 0 .. 10)
				expect(queue[i], is equal to(5 + i))
			queue free()
		})
		this add("Queue wrap negative indexing", func {
			queue := this _createQueue(10, 10, 5)
			for (i in 1 .. 11)
				expect(queue[-i], is equal to(15 - i))
			queue free()
		})
		this add("Dequeue using default value", func {
			queue := VectorQueue<MyCover> new(2)
			queue enqueue(MyCover new(1))
			queue enqueue(MyCover new(2))
			expect(queue peek(MyCover new(0)) content, is equal to(1))
			expect(queue dequeue(MyCover new(7)) content, is equal to(1))
			expect(queue dequeue(MyCover new(3)) content, is equal to(2))
			expect(queue empty, is true)
			expect(queue dequeue(MyCover new(4)) content, is equal to(4))
			queue free()
		})
		this add("Dequeue using default null", func {
			defaultValue := MyClass new(7)
			queue := VectorQueue<MyClass> new(2)
			queue enqueue(MyClass new(1))
			queue enqueue(MyClass new(2))
			expect(queue peek(defaultValue) content, is equal to(1))
			item := queue dequeue(defaultValue)
			expect(item content, is equal to(1))
			item free()
			item = queue dequeue(defaultValue)
			expect(item content, is equal to(2))
			expect(queue empty, is true)
			expect(queue dequeue(null), is Null)
			(defaultValue, item, queue) free()
		})
		this add("First/Last properties", func {
			queue := VectorQueue<Int> new(7)
			queue enqueue(1) . enqueue(2) . enqueue(3)
			expect(queue first, is equal to(1))
			expect(queue last, is equal to(3))
			queue first = 17
			queue last = 19
			expect(queue first, is equal to(17))
			expect(queue last, is equal to(19))
			expect(queue count, is equal to(3))
			queue enqueue(10)
			expect(queue last, is equal to(10))
			expect(queue count, is equal to(4))
			queue free()
		})
	}
	_createQueue: func (capacity, fill: Int, replace := 0) -> VectorQueue<Int> {
		result := VectorQueue<Int> new(capacity)
		for (i in 0 .. fill)
			result enqueue(i)
		for (i in 0 .. replace)
			result dequeue(Int minimumValue)
		for (i in 0 .. replace)
			result enqueue(fill + i)
		result
	}
}

VectorQueueTest new() run() . free()
