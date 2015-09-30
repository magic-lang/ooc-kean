use ooc-base
import threading/Thread, os/Time

TestClass: class implements IDisposable {
	refCounter: ReferenceCounter
	init: func {
		refCounter = ReferenceCounter new(this)
	}
	dispose: func {
		refCounter decrease()
	}
}

obj := TestClass new()

thread1 := Thread new(func1)
thread2 := Thread new(func2)

thread1 start()
thread2 start()

func1: func {
	for (i in 0 .. 10) {
		obj1 := obj
		Time sleepMilli(100)
	}
}

func2: func {
	for (i in 0 .. 10) {
		obj2 := obj
		Time sleepMilli(76)
	}
}

thread1 wait()
thread2 wait()

"SynchronizedTest [TODO: Not implemented as a fixture!]"
