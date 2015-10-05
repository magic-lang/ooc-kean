use ooc-collections
use ooc-base
import structs/LinkedList
import threading/Thread
import os/Time

_Task: abstract class {
	_state := _PromiseState Unfinished
	_mutex: Mutex
	mutex ::= this _mutex
	run: abstract func (mutex: Mutex)
	wait: func -> Bool {
		_mutexUpdateTime: static Int = 1
		status := false
		while (!status) {
			this _mutex lock()
			if (this _state != _PromiseState Unfinished) {
				status = (this _state == _PromiseState Finished)
				this _mutex unlock()
				break
			}
			this _mutex unlock()
			Time sleepMilli(_mutexUpdateTime)
		}
		status
	}
	cancel: func -> Bool {
		status := false
		this _mutex lock()
		if (this _state == _PromiseState Unfinished) {
			this _state = _PromiseState Cancelled
			status = true
		}
		this _mutex unlock()
		status
	}
	_finishedTask: func {
		this _mutex lock()
		if (this _state != _PromiseState Cancelled)
			this _state = _PromiseState Finished
		this _mutex unlock()
	}
}

_ActionTask: class extends _Task {
	_action: Func
	init: func (=_action, =_mutex)
	run: func (=_mutex) {
		this _action()
		this _finishedTask()
	}
}

_ResultTask: class <T> extends _Task {
	_result: Cell<T>
	_action: Func -> T
	init: func (=_action, =_mutex)
	run: func (=_mutex) {
		temporary := Cell<T> new(this _action())
		this _result = temporary
		this _finishedTask()
	}
}

_TaskPromise: class extends Promise {
	_task: _Task
	init: func (=_task)
	free: override func {
		this _task free()
		super()
	}
	wait: func -> Bool {
		this _task wait()
	}
	wait: func ~timeout (seconds: Double) -> Bool {
		timer := ClockTimer new()
		status := false
		while (timer stop() < seconds && !status) {
			status = this _task _state == _PromiseState Unfinished
		}
		timer free()
		status
	}
	cancel: override func -> Bool {
		//TODO: Interrupt executing thread and have it move on to the next task in queue
		this _task cancel()
	}
}

_TaskFuture: class <T> extends Future<T> {
	_task: _ResultTask<T>
	init: func (=_task)
	free: override func {
		this _task free()
		super()
	}
	wait: func -> Bool {
		this _task wait()
	}	
	wait: func ~timeout (seconds: Double) -> Bool {
		timer := ClockTimer new()
		status := false
		while (timer stop() < seconds && !status) {
			status = this _task _state == _PromiseState Unfinished
		}
		timer free()
		status
	}
	getResult: func (defaultValue: T) -> T {
		status := (this _task _state == _PromiseState Finished)
		status ? this _task _result[T] : defaultValue
	}
	cancel: override func -> Bool {
		//TODO: Interrupt executing thread and have it move on to the next task in queue
		this _task cancel()
	}
}

Worker: class {
	_thread: Thread
	_tasks: BlockedQueue<_Task>
	_mutex := Mutex new()
	_threadClosure: Func
	mutex ::= this _mutex
	init: func (=_tasks) {
		this _threadClosure = func { this _threadLoop() }
		this _thread = Thread new(this _threadClosure)
		this _thread start()
	}
	free: override func {
		this _thread wait()
		this _thread free()
		(this _threadClosure as Closure) dispose()
		this _mutex destroy()
		super()
	}
	_threadLoop: func {
		while (true) {
			isOk := true
			job := this _tasks wait(isOk&)
			if (isOk)
				job run(this _mutex)
			else
				break
		}
	}
}

ThreadPool: class {
	_globalMutex := Mutex new()
	_workers: Worker[]
	_tasks := BlockedQueue<_Task> new()
	_threadCount: Int
	threadCount ::= this _threadCount
	init: func (threadCount := 4) {
		this _threadCount = threadCount
		this _workers = Worker[threadCount] new()
		for (i in 0 .. threadCount)
			this _workers[i] = Worker new(this _tasks)
	}
	free: override func {
		this _tasks cancel()
		for (i in 0 .. this _threadCount) {
			this _workers[i] free()
		}
		this _workers free()
		this _tasks free()
		this _globalMutex destroy()
		super()
	}
	_add: func (task: _Task) -> Void {
		this _tasks enqueue(task)
	}
	add: func (action: Func) {
		task := _ActionTask new(action, this _globalMutex)
		this _add(task)
	}
	getPromise: func (action: Func) -> Promise {
		task := _ActionTask new(action, this _globalMutex)
		this _add(task)
		_TaskPromise new(task)
	}
	getFuture: func <T> (action: Func -> T) -> Future<T> {
		task := _ResultTask <T> new(action, this _globalMutex)
		this _add(task)
		_TaskFuture new(task)
	}
}
