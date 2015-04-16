import VectorList

Queue: class <T> {
	//TODO: Use something more efficient than a VectorList
	_list := VectorList<T> new()
	empty ::= this _list empty
	count ::= this _list count
	init: func
	queue: virtual func (item: T) { this _list add(item) }
	dequeue: virtual func -> T { this _list remove(0) }
	clear: virtual func { this _list clear() }
	free: override func {
		this _list free()
		super()
	}
}

import threading/Thread, threading/native/ConditionUnix

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	_populated := ConditionUnix new()
	empty: Bool { get {
			this _mutex lock()
			result := this _list empty
			this _mutex unlock()
			result
		}
	}
	init: func
	queue: override func (item: T) {
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
	clear: override func {
		this _mutex lock()
		super()
		this _mutex unlock()
	}
	free: override func {
		this _mutex destroy()
		super()
	}
	wait: func {
		this _mutex lock()
		if (this _list empty)
			this _populated wait(this _mutex)
		this _mutex unlock()
	}
}
