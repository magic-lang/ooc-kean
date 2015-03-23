import VectorList

Queue: class <T> {
	//TODO: Use something more efficient than a VectorList
	_list := VectorList<T> new()
	empty ::= this _list empty
	init: func
	queue: virtual func (item: T){ this _list add(item) }
	dequeue: virtual func -> T { this _list remove(0) }
	clear: virtual func { this _list clear() }
	free: override func {
		this _list free()
		super()
	}
}

import threading/Thread

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	empty: Bool { get {
			this _mutex lock()
			result := this _list empty
			this _mutex unlock()
			result
		}
	}
	init: func
	queue: override func (item: T){
		this _mutex lock()
		super(item)
		this _mutex unlock()
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
}
