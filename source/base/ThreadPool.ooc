use ooc-collections
use ooc-base

import structs/LinkedList
import threading/Thread
import threading/native/ConditionUnix
import os/Time

_TaskState: enum {
	Unfinished
	Finished
	Cancelled
}

_Task: class {
	_mutex: Mutex
	_action: Func
	_state : _TaskState
	_freeDirectly: Bool
	init: func (=_action, =_mutex) {
		_state = _TaskState Unfinished
		_mutex = Mutex new()
	}
	free: override func {
		if (this _state != _TaskState Unfinished)
			this _freeDirectly = true
		else
			super()
	}
	run: virtual func (=_mutex) {
		this _action()
		_mutex lock()
		if (this _state != _TaskState Cancelled)
			this _state = _TaskState Finished
		_mutex unlock()
		if (this _freeDirectly)
			this free()
	}
}

_ResultTask: class <T> extends _Task {
	_result: Cell<T>
	_resultAction: Func -> T
	init: func (=_resultAction, =_mutex) {
		this _state = _TaskState Unfinished
	}
	free: func {
		if (this _state != _TaskState Unfinished)
			this _freeDirectly = true
		else
			super()
	}
	run: override func (=_mutex) {
		temporary := Cell<T> new(this _resultAction())
		this _mutex lock()
		this _result = temporary
		if (this _state != _TaskState Cancelled)
			this _state = _TaskState Finished
		if (this _freeDirectly)
			this free()
		this _mutex unlock()
	}
}

_TaskPromise: class extends Promise {
	_task: _Task
	init: func (=_task)
	free: override func {
		this _task free()
		super()
	}
	wait: override func -> Bool {
		status := false
		while (true) {
			this _task _mutex lock()
			if (this _task _state != _TaskState Unfinished) {
				status = (this _task _state == _TaskState Finished)
				this _task _mutex unlock()
				break
			}
			this _task _mutex unlock()
			Time sleepMilli(10)
		}
		status
	}
	cancel: override func -> Bool {
		status := false
		this _task _mutex lock()
		if (this _task _state == _TaskState Unfinished) {
			this _task _state = _TaskState Cancelled
			status = true
		}
		this _task _mutex unlock()
		status
	}
}

_ResultTaskPromise: class <T> extends ResultPromise<T> {
	_resultTask: _ResultTask<T>
	init: func (=_resultTask)
	free: override func {
		this _resultTask free()
		super()
	}
	wait: func -> Bool {
		status := false
		while (true) {
			this _resultTask _mutex lock()
			if (this _resultTask _state != _TaskState Unfinished) {
				status = (this _resultTask _state == _TaskState Finished)
				this _resultTask _mutex unlock()
				break
			}
			this _resultTask _mutex unlock()
			Time sleepMilli(100)
		}
		status
	}
	wait: func ~default (defaultValue: T) -> T {
		status := this wait()
		status ? this _resultTask _result[T] : defaultValue
	}
	cancel: override func -> Bool {
		status := false
		this _resultTask _mutex lock()
		if (this _resultTask _state == _TaskState Unfinished) {
			this _resultTask _state = _TaskState Cancelled
			status = true
		}
		this _resultTask _mutex unlock()
		status
	}
}

ThreadPool: class {
	_globalmutex := Mutex new()
	_threads: Thread[]
	_threadMutexes: Mutex[]
	_tasks := BlockedQueue<_Task> new()
	_allFinishedCondition := WaitCondition new()
	_activeJobs: Int
	_threadCount: Int
	threadCount ::= this _threadCount
	init: func (threadCount := 4) {
		this _threadCount = threadCount
		this _threads = Thread[threadCount] new()
		this _threadMutexes = Mutex[threadCount] new()
		for (i in 0 .. threadCount) {
			this _threadMutexes[i] = Mutex new()
			this _threads[i] = Thread new(|| threadLoop(i))
			this _threads[i] start()
		}
	}
	free: override func {
		for (i in 0 .. this _threadCount) {
			this _threads[i] free()
			this _threadMutexes[i] destroy()
		}			
		gc_free(this _threads data)
		this _tasks free()
		this _allFinishedCondition free()
		this _globalmutex destroy()
		super()
	}
	threadLoop: func (threadId: Int) {
		while (true) {
			job := this _tasks wait()
			job run(this _threadMutexes[threadId])
			this _globalmutex lock()
			this _activeJobs -= 1
			if (this _activeJobs == 0) {
				this _allFinishedCondition broadcast()
			}
			this _globalmutex unlock()
		}
	}
	_add: func (task: _Task) -> Void {
		this _globalmutex lock()
		this _activeJobs += 1
		this _globalmutex unlock()
		this _tasks enqueue(task)
	}
	add: func (action: Func) {
		task := _Task new(action, this _globalmutex)
		this _add(task)
	}
	addWait: func (action: Func) -> Promise {
		task := _Task new(action, this _globalmutex)
		this _add(task)
		_TaskPromise new(task)
	}
	addWaitResult: func ~result <T> (action: Func -> T) -> ResultPromise<T> {
		task := _ResultTask<T> new(action, this _globalmutex)
		this _add(task)
		_ResultTaskPromise new(task)
	}
	waitAll: func {
		this _globalmutex lock()
		if (this _activeJobs > 0)
			this _allFinishedCondition wait(this _globalmutex)
		this _globalmutex unlock()
	}
}
