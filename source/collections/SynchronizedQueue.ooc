import Queue
import threading/Thread
import threading/native/ConditionUnix

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	_populated := ConditionUnix new()
	capacity: Int { get {
			this _mutex lock()
			result := this capacity()
			this _mutex unlock()
			result
		}
	}
	count: Int { get {
			this _mutex lock()
			result := this count()
			this _mutex unlock()
			result
		}
	}
	empty: Bool { get {
			this _mutex lock()
			result := this empty()
			this _mutex unlock()
			result
		}
	}
	full: Bool { get {
			this _mutex lock()
			result := this full()
			this _mutex unlock()
			result
		}
	}

	init: func (capacity: Int) {
		super(capacity)
	}

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
		if (this empty())
			this _populated wait(this _mutex)
		this _mutex unlock()
	}
}
