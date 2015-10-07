use ooc-unit
import threading/Thread

MutexTest: class extends Fixture {
	init: func {
		super("Mutex")
		this add("basic", This _testBasicUsage)
	}
	_testBasicUsage: static func {
		threadCount := 4
		countPerThread := 1_000
		mutex := Mutex new()
		value := Cell<Int> new(0)
		threads := Thread[threadCount] new()
		job := func {
			for (i in 0 .. countPerThread) {
				mutex lock()
				value set(value get() + 1)
				mutex unlock()
				Thread yield()
			}
		}
		for (i in 0 .. threads length) {
			threads[i] = Thread new(|| job())
			expect(threads[i] start())
		}
		for (i in 0 .. threads length) {
			expect(threads[i] wait())
			threads[i] free()
		}
		threads free()
		mutex free()
		expect(value get() == countPerThread * threadCount)
	}
}

MutexTest new() run()
