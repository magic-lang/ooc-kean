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
	wait: abstract func ~timeout (seconds: Double) -> Bool
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
	wait: func ~timeout (seconds: Double) -> Bool {
		if (this _state == _PromiseState Unfinished)
			this _thread wait(seconds)
		this _state == _PromiseState Finished
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished)
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
	wait: abstract func ~timeout (seconds: Double) -> Bool
	wait: virtual func ~default (defaultValue: T) -> T {
		status := this wait()
		status ? this getResult(defaultValue) : defaultValue
	}
	wait: virtual func ~defaulttimeout (seconds: Double, defaultValue: T) -> T {
		status := this wait(seconds)
		status ? this getResult(defaultValue) : defaultValue
	}
	getResult: abstract func (defaultValue: T) -> T
	cancel: virtual func -> Bool { false }
	start: static func<S> (S: Class, action: Func -> S) -> This<S> {
		_ThreadFuture<S> new(action)
	}
}

_ThreadFuture: class <T> extends Future<T> {
	_result: Object
	_action: Func
	_thread: Thread
	_mutex := Mutex new()
	_hasCover := false
	init: func (task: Func -> T) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			temporary := task()
			if (T inheritsFrom?(Object))
				this _result = temporary
			else {
				this _result = Cell<T> new(temporary)
				this _hasCover = true
			}
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
	wait: func ~timeout (seconds: Double) -> Bool {
		if (this _state == _PromiseState Unfinished)
			this _thread wait(seconds)
		this _state == _PromiseState Finished
	}
	getResult: func (defaultValue: T) -> T {
		result := defaultValue
		if (this _state == _PromiseState Finished) {
			if (this _hasCover)
				result = this _result as Cell<T> get()
			else
				result = this _result
		}
		result
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished)
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
