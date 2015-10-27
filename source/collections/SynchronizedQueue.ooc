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
		this _mutex free()
		super()
	}
	enqueue: override func (item: T) {
		this _mutex lock()
		this _backend enqueue(item)
		this _mutex unlock()
	}
	dequeue: func ~default (fallback: T) -> T {
		this _mutex lock()
		result := this _backend dequeue(fallback)
		this _mutex unlock()
		result
	}
	peek: func ~default (fallback: T) -> T {
		this _mutex lock()
		result := this _backend peek(fallback)
		this _mutex unlock()
		result
	}
	clear: func {
		this _mutex lock()
		this _backend clear()
		this _mutex unlock()
	}
}

BlockedQueue: class <T> extends SynchronizedQueue<T> {
	_populated := WaitCondition new()
	_canceled := false
	init: func { super() }
	free: override func {
		this _populated free()
		super()
	}
	enqueue: override func (item: T) {
		super(item)
		this _populated signal()
	}
	cancel: func {
		this _mutex lock()
		this _canceled = true
		this _mutex unlock()
		this _populated broadcast()
	}
	wait: func (isOk := null as Bool*) -> T {
		result: T
		this _mutex lock()
		while (this empty) {
			this _populated wait(this _mutex)
			if (this _canceled) {
				if (isOk)
					isOk@ = false
				break
			}
		}
		if (!this _canceled)
			result = this _backend dequeue(result)
		this _mutex unlock()
		result
	}
}
