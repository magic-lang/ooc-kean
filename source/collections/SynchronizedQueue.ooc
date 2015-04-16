import Queue
import threading/Thread
import threading/native/ConditionUnix

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	_populated := ConditionUnix new()
	init: func (capacity := 32) { super(capacity) }
	free: override func {
		this _mutex destroy()
		super()
	}
	enqueue: override func (item: T) {
		this _mutex lock()
		super(item)
		this _mutex unlock()
		this _populated broadcast()
	}
	dequeue: override func -> T {
		this _mutex lock()
		result := super()
		this _mutex unlock()
		result
	}
	peek: override func -> T {
		this _mutex lock()
		result := super()
		this _mutex unlock()
		result
	}
	wait: func {
		this _mutex lock()
		if (this empty)
			this _populated wait(this _mutex)
		this _mutex unlock()
	}
}
