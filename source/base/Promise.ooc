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
	init: func (=_action) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			_action()
			this _mutex lock()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			this _mutex unlock()
		}
		this _thread = Thread new(|| this _action())
		this _thread start()
	}
	free: func {
		_thread free()
		super()
	}
	wait: func -> Bool {
		this _thread wait()
		status := false
		this _mutex lock()
		status = this _state == _PromiseState Finished
		this _mutex unlock()
		status
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

ResultPromise: abstract class <T> {
	_state: _PromiseState
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~default (defaultValue: T) -> T
	cancel: virtual func -> Bool { false }
	start: static func<S> (S: Class, action: Func -> S) -> This<S> {
		_ThreadResultPromise<S> new(action)
	}
}

_ThreadResultPromise: class <T> extends ResultPromise<T> {
	_result: Cell<T>
	_action: Func -> T
	_task: Func
	_thread: Thread
	_mutex := Mutex new()
	init: func (=_action) {
		super()
		this _state = _PromiseState Unfinished
		this _task = func {
			temporary := this _action()
			this _result = Cell<T> new(temporary)
			this _mutex lock()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			this _mutex unlock()
		}
		this _thread = Thread new(|| this _task())
		this _thread start()
	}
	free: func {
		_thread free()
		_mutex destroy()
		super()
	}
	wait: func -> Bool {
		this _thread wait()
		(this _state == _PromiseState Finished)
	}
	wait: func ~default (defaultValue: T) -> T {
		status := this wait()
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
