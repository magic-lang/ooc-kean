/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use concurrent
import threading/Thread

_PromiseState: enum {
	Unfinished
	Finished
	Cancelled
}

Promise: abstract class {
	_state: _PromiseState
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~timeout (seconds: Double) -> Bool
	cancel: virtual func -> Bool { false }
	operator + (other: This) -> PromiseCollector {
		collector := PromiseCollector new()
		collector add(this)
		collector add(other)
		collector
	}
	kean_concurrent_promise_wait: unmangled func { this wait() }
	kean_concurrent_promise_waitWithTimeout: unmangled func (timeout: Double) { this wait(timeout) }
	kean_concurrent_promise_free: unmangled func { this free() }
	start: static func (action: Func) -> This { _ThreadPromise new(action) }
	empty: static This { get { _EmptyPromise new() } }
}

_EmptyPromise: class extends Promise {
	init: func { super() }
	wait: override func -> Bool { true }
	wait: override func ~timeout (seconds: Double) -> Bool { true }
}

_ThreadPromise: class extends Promise {
	_action: Func
	_thread: Thread
	_threadAlive := true
	_freeOnCompletion := false
	init: func (task: Func) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			task()
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			if (this _freeOnCompletion) {
				this _threadAlive = false
				this free()
			}
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _threadAlive) {
			this _freeOnCompletion = true
			this _thread detach()
		} else {
			this _thread free()
			(this _action as Closure) free()
			super()
		}
	}
	wait: override func -> Bool {
		if (this _threadAlive)
			if (this _thread wait())
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	wait: override func ~timeout (seconds: Double) -> Bool {
		if (this _threadAlive)
			if (this _thread wait(seconds))
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished) {
			this _thread cancel()
			this _state = _PromiseState Cancelled
		}
		this _state == _PromiseState Cancelled
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
	_threadAlive := true
	_freeOnCompletion := false
	init: func (task: Func -> T) {
		super()
		this _state = _PromiseState Unfinished
		this _action = func {
			temporary := task()
			if (T inheritsFrom(Object))
				this _result = temporary
			else
				this _result = Cell<T> new(temporary)
			if (this _state != _PromiseState Cancelled)
				this _state = _PromiseState Finished
			if (this _freeOnCompletion) {
				this _threadAlive = false
				this free()
			}
		}
		this _thread = Thread new(this _action)
		this _thread start()
	}
	free: override func {
		if (this _threadAlive) {
			this _freeOnCompletion = true
			this _thread detach()
		} else {
			this _thread free()
			(this _action as Closure) free()
			super()
		}
	}
	wait: override func -> Bool {
		if (this _threadAlive)
			if (this _thread wait())
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	wait: override func ~timeout (seconds: Double) -> Bool {
		if (this _threadAlive)
			if (this _thread wait(seconds))
				this _threadAlive = false
		this _state == _PromiseState Finished
	}
	getResult: override func (defaultValue: T) -> T {
		result := defaultValue
		if (this _state == _PromiseState Finished && this _result != null)
			if (T inheritsFrom(Object))
				result = this _result
			else
				result = (this _result as Cell<T>) get()
		result
	}
	cancel: override func -> Bool {
		if (this _state == _PromiseState Unfinished) {
			this _thread cancel()
			this _state = _PromiseState Cancelled
		}
		this _state == _PromiseState Unfinished
	}
}
