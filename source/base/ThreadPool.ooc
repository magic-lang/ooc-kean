import structs/LinkedList
import threading/Thread
import threading/native/ConditionUnix

ThreadJob: class {
	_pool: ThreadPool
	_finishedCondition: ConditionUnix
	finishedCondition ::= this _finishedCondition
	_body: Func
	_finished := false
	finished ::= this _finished
	init: func (=_body, =_pool) { this _finishedCondition = ConditionUnix new() }
	execute: func {
		this _body()
		this _finishedCondition broadcast()
	}
	finish: func {
		this _finished = true
	}
	wait: func {
		this _pool wait(this)
	}
}

ThreadPool: class {
	_jobs: LinkedList<ThreadJob>
	_threads: Thread[]
	_mutex: Mutex
	_newJobCondition: ConditionUnix
	_allFinishedCondition: ConditionUnix
	_activeJobs: Int
	_threadCount: Int
	threadCount ::= this _threadCount

	init: func (threadCount := 4) {
		this _threadCount = threadCount
		this _threads = Thread[threadCount] new()
		this _jobs = LinkedList<ThreadJob> new()
		this _mutex = Mutex new()
		this _newJobCondition = ConditionUnix new()
		this _allFinishedCondition = ConditionUnix new()

		for(i in 0..threadCount) {
			this _threads[i] = Thread new(|| threadLoop())
			this _threads[i] start()
		}
	}
	threadLoop: func {
		while(true) {
			this _mutex lock()
			if(this _jobs getSize() > 0) {
				job := this _jobs first()
				this _jobs removeAt(0)
				this _mutex unlock()
				job execute()
				this _mutex lock()
				job finish()
				this _activeJobs -= 1
				if(this _activeJobs == 0)
					this _allFinishedCondition broadcast()
				this _mutex unlock()
			} else {
				this _newJobCondition wait(this _mutex)
				this _mutex unlock()
			}
		}
	}
	add: func (body: Func) -> ThreadJob {
		this _mutex lock()
		job := ThreadJob new(body, this)
		this _jobs add(job)
		this _activeJobs += 1
		this _newJobCondition broadcast()
		this _mutex unlock()
		job
	}
	waitAll: func {
		this _mutex lock()
		if (this _activeJobs > 0) {
			this _allFinishedCondition wait(this _mutex)
			this _mutex unlock()
		} else {
			this _mutex unlock()
		}
	}
	wait: func (job: ThreadJob) {
		this _mutex lock()
		if (!job finished)
			job finishedCondition wait(this _mutex)
		this _mutex unlock()
	}


}
