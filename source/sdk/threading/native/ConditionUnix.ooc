
include pthread
PThreadCond: cover from pthread_cond_t
PThreadCondAttr: cover from pthread_condattr_t

pthread_cond_init: extern func (cond: PThreadCond*, attr: PThreadCondAttr*) -> Int
pthread_cond_signal: extern func (cond: PThreadCond*) -> Int
pthread_cond_broadcast: extern func (cond: PThreadCond*) -> Int
pthread_cond_wait: extern func (cond: PThreadCond*, mutex: PThreadMutex*) -> Int
pthread_cond_destroy: extern func (cond: PThreadCond*) -> Int

import ../Thread
import MutexUnix

ConditionUnix: class {
  _backend: PThreadCond*

  init: func {
      this _backend = gc_malloc(PThreadCond size) as PThreadCond*
      result := pthread_cond_init(this _backend, null)
      if (result != 0)
      	raise("Something went wrong when calling pthread_cond_init")
  }
  wait: func (mutex: Mutex) -> Bool {
    result := pthread_cond_wait(this _backend, mutex as PThreadMutex*)
    result == 0
  }
  signal: func -> Bool {
    result := pthread_cond_signal(this _backend)
    result == 0
  }
  broadcast: func -> Bool {
    result := pthread_cond_broadcast(this _backend)
    result == 0
  }
  destroy: func -> Bool {
    result := pthread_cond_destroy(this _backend)
    result == 0
  }
}
