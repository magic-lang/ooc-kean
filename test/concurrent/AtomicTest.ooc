use concurrent
use unit

AtomicTest: class extends Fixture {
	_value := static AtomicInt new(0)
	init: func {
		super("Atomic")
		this add("read write", This _testReadWrite)
	}
	_testReadWrite: static func {
		expect(_value get(), is equal to(0))
		_value set(13)
		expect(_value get(), is equal to(13))
		_value subtract(2)
		expect(_value get(), is equal to(11))
		expect(_value swap(0), is equal to(11))
		expect(_value get(), is equal to(0))
		range := 10000
		numberOfThreads := 7
		job := func {
			for (_ in 0 .. range)
				_value add(1)
		}
		threads: Thread[numberOfThreads]
		for (i in 0 .. numberOfThreads)
			threads[i] = Thread new(job)
		for (i in 0 .. numberOfThreads)
			threads[i] start()
		for (i in 0 .. numberOfThreads)
			threads[i] wait() . free()
		expect(_value get(), is equal to(range * numberOfThreads))
		(job as Closure) free()
	}
}

AtomicTest new() run() . free()
