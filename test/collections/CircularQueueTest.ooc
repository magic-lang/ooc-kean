/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

 use collections
 use unit

MyClass: class {
	instanceCount := static 0
	content: Int
	init: func (=content) { This instanceCount += 1 }
	init: func ~default { this init(0) }
	increase: func { this content += 1 }
	free: override func {
		This instanceCount -= 1
		super()
	}
}

CircularQueueTest: class extends Fixture {
	init: func {
		super("CircularQueue")
		this add("with cover", func {
			queue := CircularQueue<Int> new(3)
			queue enqueue(1)
			queue enqueue(2)
			queue enqueue(3)
			queue enqueue(4)
			expect(queue count, is equal to(3))
			expect(queue dequeue(0), is equal to(2))
			expect(queue dequeue(0), is equal to(3))
			expect(queue dequeue(0), is equal to(4))
			expect(queue empty, is true)
			queue free()
		})
		this add("with class", func {
			initialCount := MyClass instanceCount
			queue := CircularQueue<MyClass> new(3)
			queue enqueue(MyClass new(1))
			queue enqueue(MyClass new(2))
			queue enqueue(MyClass new(3))
			queue enqueue(MyClass new(4))
			expect(queue count, is equal to(3))
			object := queue dequeue(null)
			expect(object, is notNull)
			expect(object content, is equal to(2))
			object free()
			object = queue dequeue(null)
			expect(object content, is equal to(3))
			(object, queue) free()
			expect(MyClass instanceCount, is equal to(initialCount))
		})
		this add("First/Last properties", func {
			queue := CircularQueue<Int> new(3)
			queue enqueue(1) . enqueue(2) . enqueue(3)
			expect(queue first, is equal to(1))
			expect(queue last, is equal to(3))
			queue first = 17
			queue last = 19
			expect(queue first, is equal to(17))
			expect(queue last, is equal to(19))
			queue enqueue(10)
			expect(queue first, is equal to(2))
			expect(queue last, is equal to(10))
			queue enqueue(15)
			expect(queue first, is equal to(19))
			expect(queue last, is equal to(15))
			queue free()
		})
	}
}

CircularQueueTest new() run() . free()
