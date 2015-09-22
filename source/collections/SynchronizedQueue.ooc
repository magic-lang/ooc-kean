import Queue
import threading/Thread

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	_backend: Queue<T>
	count ::= this _backend count
	empty ::= this _backend empty
	init: func {
		super()
		this _backend = VectorQueue<T> new()
	}
	free: override func {
		this _backend free()
		this _mutex destroy()
		super()
	}
	enqueue: override func (item: T) {
		this _mutex lock()
		this _backend enqueue(item)
		this _mutex unlock()
	}
	dequeue: func ~out (result: T*) -> Bool {
		this _mutex lock()
		success := this _backend dequeue(result)
		this _mutex unlock()
		success
	}
	dequeue: func -> (T, Bool) {
		result: T
		success := this dequeue(result&)
		(result, success)
	}
	peek: func ~out (result: T*) -> Bool {
		this _mutex lock()
		success := this _backend peek(result)
		this _mutex unlock()
		success
	}
	peek: func -> (T, Bool) {
		result: T
		success := this peek(result&)
		(result, success)
	}
	clear: func {
		this _mutex lock()
		this _backend clear()
		this _mutex unlock()
	}
}

BlockedQueue: class <T> extends SynchronizedQueue<T> {
	_populated := WaitCondition new()
	init: func { super() }
	free: override func {
		this _populated free()
		super()
	}
	enqueue: override func (item: T) {
		super(item)
		this _populated signal()
	}
	wait: func -> T {
		result: T
		this _mutex lock()
		while (this empty)
			this _populated wait(this _mutex)
		this _backend dequeue(result&) as Void // Ignore the return value to avoid build warning
		this _mutex unlock()
		result
	}
}
