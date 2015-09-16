import threading/Thread
import os/Time

PromiseState: enum {
	Running
	Completed
	Cancelled
	Error
}

Promise: abstract class<T> {
	_result: T
	_state: PromiseState
	state ::= this _state

	init: func

	wait: abstract func -> T { _result }

	wait: virtual func ~timeout (seconds: Double) -> T { _result }

	cancel: virtual func -> Bool { false }

	_execute: virtual func
}

ThreadedPromise : class<T> extends Promise<T> {
	_mutex := Mutex new()
	_thread: Thread
	_task: Func
	_exception: Exception

	init: func (task: Func -> T) {
		this _task = func () -> Void {
			try {
				temporary := task()
				this _mutex lock()
				this _result = temporary
				this _state = PromiseState Completed
				this _mutex unlock()
			}
			catch (e: Exception) {
				this _exception = e
			}
		}

		this _execute()
	}

	wait: func -> T {
		Running := true

		while (Running) {
			Time sleepMilli(10)
			_mutex lock()
			if (this _state != PromiseState Running) {
			Running = false
			}
			_mutex unlock()
		}

		if (this _state == PromiseState Error) {
			_exception throw()
		}

		_result
	}

	wait: func ~timeout (seconds: Double) -> T {
		_thread.wait(seconds)
		_result
	}

	cancel: func -> Void {
		this _state = PromiseState Cancelled
		//How to terminate thread?
	}

	_execute: override func {
		try {
			this _state = PromiseState Running

			this _thread = Thread new(||
			this _task()
			)

			this _thread start()
		} catch (exception: Exception) {
			this _state = PromiseState Error
			this _exception = exception
		}
	}
}
