/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent
use collections
use unit

TestObject: class extends SynchronizedResource {
	recycler := static SynchronizedResourceRecycler new()
	objectCounter: static Int = 0
	objectId := 0
	value: Int { get set }
	init: func (=value) {
		super()
		This objectCounter += 1
		this objectId = This objectCounter
	}
	free: override func {
		if (this _recycle)
			This recycler recycle(this)
		else
			super()
	}
	new: static func ~recycled (value: Int) -> This {
		withSettings := func (recycled: SynchronizedResource) -> Bool {
			(recycled as This) value == value
		}
		object := This recycler create(withSettings)
		result := (object != null) ? object as This : This new(value)
		(withSettings as Closure) free()
		result
	}
}

SynchronizedResourceTest: class extends Fixture {
	init: func {
		super("SynchronizedResource")
		this add("single thread", func {
			object := TestObject new~recycled(3)
			counter := object objectId
			object free()
			recycledObjects := TestObject recycler _resources get(Thread currentThreadId())
			expect(recycledObjects, is notNull)
			expect(recycledObjects count, is equal to(1))
			object = TestObject new~recycled(3)
			expect(object checkThreadAffinity())
			expect(recycledObjects count, is equal to(0))
			expect(object objectId, is equal to(counter))
			object free()
			object = TestObject new~recycled(16)
			expect(recycledObjects count, is equal to(1))
			expect(counter != object objectId)
			expect(object value, is equal to(16))
			object free()
			expect(recycledObjects count, is equal to(2))
		})
		this add("multiple threads", This _testMultipleThreads)
	}
	_testMultipleThreads: static func {
		thisThreadResources := TestObject recycler _resources get(Thread currentThreadId())
		count := thisThreadResources count
		numberOfThreads := 4
		objectsPerThread := 1024
		differentObjects := 256
		expect(count, is greater than(0))
		objectFromMainThread := thisThreadResources[0]
		validResult := true
		globalMutex := Mutex new(MutexType Global)
		threadFunc := func {
			if (objectFromMainThread checkThreadAffinity() == true)
				globalMutex with(|| validResult = false)
			for (i in 0 .. objectsPerThread) {
				value := i % differentObjects
				object := TestObject new~recycled(value)
				if (object value != value || object checkThreadAffinity() == false)
					globalMutex with(|| validResult = false)
				object free()
				localResources := TestObject recycler _resources get(Thread currentThreadId())
				if (localResources == null || localResources count != (i + 1) minimum(differentObjects))
					globalMutex with(|| validResult = false)
			}
		}
		threads: Thread[numberOfThreads]
		for (i in 0 .. numberOfThreads) {
			threads[i] = Thread new(threadFunc)
			threads[i] start()
		}
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(validResult, is true)
		expect(thisThreadResources count, is equal to(count))
		expect(TestObject recycler _resources keys count, is equal to(numberOfThreads + 1))
		TestObject recycler free()
		(threadFunc as Closure) free()
		globalMutex free()
	}
}

SynchronizedResourceTest new() run() . free()
