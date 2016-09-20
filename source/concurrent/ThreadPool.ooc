/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use concurrent

_Task: abstract class {
	_state := _PromiseState Unfinished
	_mutex: Mutex
	_waitCondition := WaitCondition new()
	_freeOnCompletion := false
	init: func (=_mutex)
	free: override func {
		this _mutex lock()
		if (this _state == _PromiseState Unfinished) {
			this _freeOnCompletion = true
			this _mutex unlock()
		} else {
			this _free()
			this _waitCondition free()
			this _mutex unlock()
			super()
		}
	}
	_free: abstract func
	run: abstract func
	wait: func -> Bool {
		this _mutex lock()
		while (this _state == _PromiseState Unfinished)
			this _waitCondition wait(this _mutex)
		this _mutex unlock()
		this _state == _PromiseState Finished
	}
	wait: func ~timeout (time: TimeSpan) -> Bool {
		status := false
		if (time == TimeSpan maximumValue)
			this wait()
		else {
			timer := WallTimer new() . start()
			while (timer stop() < time && !status) {
				status = (this _state != _PromiseState Unfinished)
				if (!status)
					Time sleepMilli(1)
			}
			timer free()
		}
		this _state == _PromiseState Finished
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
		if (this _freeOnCompletion) {
			this _mutex unlock()
			this free()
		} else {
			this _waitCondition broadcast()
			this _mutex unlock()
		}
	}
}

_ActionTask: class extends _Task {
	_action: Func
	init: func (=_action, mutex: Mutex) { super(mutex) }
	_free: override func { (this _action as Closure) free(Owner Receiver) }
	run: override func {
		this _action()
		this _finishedTask()
	}
}

_ResultTask: class <T> extends _Task {
	_result: __onheap__ T
	_action: Func -> T
	init: func (=_action, mutex: Mutex) { super(mutex) }
	_free: override func {
		(this _action as Closure) free(Owner Receiver)
		memfree(this _result)
	}
	run: override func {
		temporary := this _action()
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
	wait: override func (time: TimeSpan) -> Bool { this _task wait(time) }
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
	wait: override func (time: TimeSpan) -> Bool { this _task wait(time) }
	getResult: override func (defaultValue: T) -> T {
		result := defaultValue
		if (this _task _state == _PromiseState Finished)
			result = this _task _result
		result
	}
	cancel: override func -> Bool {
		//TODO: Interrupt executing thread and have it move on to the next task in queue
		this _task cancel()
	}
}

Worker: class {
	_thread: Thread
	_tasks: BlockedQueue<_Task>
	_threadClosure: Func
	init: func (=_tasks) {
		this _threadClosure = func { this _threadLoop() }
		this _thread = Thread new(this _threadClosure)
		this _thread start()
	}
	free: override func {
		this _thread wait() . free()
		(this _threadClosure as Closure) free()
		super()
	}
	_threadLoop: func {
		while (true) {
			job := this _tasks wait()
			if (job != null)
				job run()
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
		for (i in 0 .. this _threadCount)
			this _workers[i] free()
		(this _workers, this _tasks, this _globalMutex) free()
		super()
	}
	_add: func (task: _Task) -> Void { this _tasks enqueue(task) }
	add: func (action: Func) {
		task := _ActionTask new(action, this _globalMutex)
		this _add(task)
		//Enable free after completion
		task free()
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
