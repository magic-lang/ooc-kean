import structs/LinkedList
import threading/Thread

ThreadJob: class {
  init: func (=body)
  body: Func
}

ThreadPool: class {
  jobs: LinkedList<ThreadJob>
  threads: Thread[]
  mutex: Mutex
  activeJobs: Int

  init: func (threadCount := 4) {
    this threads = Thread[threadCount] new()
    this jobs = LinkedList<ThreadJob> new()
    this mutex = Mutex new()

    for(i in 0..threadCount) {
      threads[i] = Thread new(|| threadLoop())
      threads[i] start()
    }
  }
  threadLoop: func {
    while(true) {
      this mutex lock()
      if(this jobs getSize() > 0) {
        job := this jobs first()
        jobs removeAt(0)
        this mutex unlock()
        job body()
        this mutex lock()
        this activeJobs -= 1
        this mutex unlock()
      }
      else {
        this mutex unlock()
        Thread yield()
      }
    }
  }
  add: func (body: Func) {
    this mutex lock()
    this jobs add(ThreadJob new(body))
    this activeJobs += 1
    this mutex unlock()
  }

  waitAll: func {
    while(true) {
      this mutex lock()
      if (this activeJobs > 0) {
        this mutex unlock()
        Thread yield()
      }
      else {
        this mutex unlock()
        break
      }
    }
  }


}
