use ooc-collections

import structs/LinkedList
import threading/Thread
import threading/native/ConditionUnix

ThreadJob: class {
	_body: Func
	init: func (=_body)
	_execute: func { this _body() }
	run: virtual func {
		this _execute()
		this free()
	}
}

SynchronizedThreadJob: class extends ThreadJob {
	_finishedCondition := ConditionUnix new()
	_mutex := Mutex new()
	_finished := false
	finished ::= this _finished
	_freeOnCompletion := false
	init: func (body: Func) { super(body) }
	free: override func {
		this _mutex lock()
		if (!this _finished) {
			this _freeOnCompletion = true
			this _mutex unlock()
		} else {
			this _mutex unlock()
			this _mutex destroy()
			this _finishedCondition free()
			super()
		}
	}
	run: override func {
		this _execute()
		this _mutex lock()
		this _finished = true
		if (this _freeOnCompletion) {
			this _mutex unlock()
			this free()
		} else {
			this _mutex unlock()
			this _finishedCondition broadcast()
		}
	}
	wait: func {
		this _mutex lock()
		if (!this _finished)
			this _finishedCondition wait(this _mutex)
		this _mutex unlock()
	}
}

ThreadPool: class {
	_threads: Thread[]
	_jobs := BlockedQueue<ThreadJob> new()
	_mutex := Mutex new()
	_allFinishedCondition := ConditionUnix new()
	_activeJobs: Int
	_threadCount: Int
	threadCount ::= this _threadCount

	init: func (threadCount := 4) {
		this _threadCount = threadCount
		this _threads = Thread[threadCount] new()
		for (i in 0 .. threadCount) {
			this _threads[i] = Thread new(|| threadLoop())
			this _threads[i] start()
		}
	}
	free: override func {
		for (i in 0 .. this _threadCount)
			this _threads[i] free()
		gc_free(this _threads data)
		this _jobs free()
		this _allFinishedCondition free()
		this _mutex destroy()
		super()
	}
	threadLoop: func {
		while (true) {
			job := this _jobs wait()
			job run()
			this _mutex lock()
			this _activeJobs -= 1
			if (this _activeJobs == 0)
				this _allFinishedCondition broadcast()
			this _mutex unlock()
		}
	}
	_add: func (job: ThreadJob) {
		this _mutex lock()
		this _activeJobs += 1
		this _mutex unlock()
		this _jobs enqueue(job)
	}
	addSynchronized: func (body: Func) -> SynchronizedThreadJob {
		job := SynchronizedThreadJob new(body)
		this _add(job)
		job
	}
	add: func (body: Func) { this _add(ThreadJob new(body)) }
	wait: func (body: Func) { this addSynchronized(body) wait() . free() }
	waitAll: func {
		this _mutex lock()
		if (this _activeJobs > 0)
			this _allFinishedCondition wait(this _mutex)
		this _mutex unlock()
	}
}
