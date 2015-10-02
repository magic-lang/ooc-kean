use ooc-base
import threading/Thread
import os/Time

_PromiseState: enum {
	Unfinished
	Finished
	Cancelled
}

Promise: abstract class {
	_state : _PromiseState
	init: func
	wait: abstract func -> Bool
	cancel: virtual func -> Bool { false }
	start: static func (action: Func) -> This {
		_ThreadPromise new(action)
	}
	operator + (other: This) -> PromiseCollector {
		collector := PromiseCollector new()
		collector add(this)
		collector add(other)
		collector
	}
}

_ThreadPromise: class extends Promise {
	_action: Func
	_thread: Thread
	_mutex := Mutex new()
	init: func (task: Func) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			task()
			this _mutex lock()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			this _mutex unlock()
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _state == _PromiseState Unfinished)
			this _thread wait()
		this _thread free()
		(this _action as Closure) dispose()
		this _mutex destroy()
		super()
	}
	wait: func -> Bool {
		if (this _state == _PromiseState Unfinished)
			this _thread wait()
		this _state == _PromiseState Finished
	}
	cancel: override func -> Bool {
		this _thread cancel()
		status := false
		this _mutex lock()
		if (this _state == _PromiseState Unfinished) {
			this _state = _PromiseState Cancelled
			status = true
		}
		this _mutex unlock()
		status
	}
}

Future: abstract class <T> {
	_state: _PromiseState
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~default (defaultValue: T) -> T
	getResult: abstract func (defaultValue: T) -> T
	cancel: virtual func -> Bool { false }
	start: static func<S> (S: Class, action: Func -> S) -> This<S> {
		_ThreadFuture<S> new(action)
	}
}

_ThreadFuture: class <T> extends Future<T> {
	_result: Cell<T>
	_action: Func
	_thread: Thread
	_mutex := Mutex new()
	init: func (task: Func -> T) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			temporary := task()
			this _result = Cell<T> new(temporary)
			this _mutex lock()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			this _mutex unlock()
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _state == _PromiseState Unfinished)
			this _thread wait()
		this _thread free()
		(this _action as Closure) dispose()
		this _mutex destroy()
		super()
	}
	wait: func -> Bool {
		if (this _state == _PromiseState Unfinished)
			this _thread wait()
		(this _state == _PromiseState Finished)
	}
	wait: func ~default (defaultValue: T) -> T {
		status := this wait()
		status ? this _result[T] : defaultValue
	}
	getResult: func (defaultValue: T) -> T {
		this _mutex lock()
		status := (this _state == _PromiseState Finished)
		this _mutex unlock()
		status ? this _result[T] : defaultValue
	}
	cancel: override func -> Bool {
		this _thread cancel()
		status := false
		this _mutex lock()
		if (this _state == _PromiseState Unfinished) {
			this _state = _PromiseState Cancelled
			status = true
		}
		this _mutex unlock()
		status
	}
}
