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

  init: func() { }

  wait: abstract func -> T { _result}

  wait: virtual func ~timeout (seconds: Double) -> T { _result}

  cancel: virtual func() -> Bool { false }

  _execute: virtual func { }
}

ThreadedPromise : class<T> extends Promise<T> {
  _mutex := Mutex new()
  _thread: Thread
  _task: Func

  init: func (task: Func -> T) {
    this _task = func () -> Void {
        temporary := task()
        this _mutex lock()
        this _result = temporary
        this _state = PromiseState Completed
        this _mutex unlock()
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
      // Vhat to do on error?
    }

    _result
  }

  wait: func ~timeout (seconds: Double) -> T {
    _thread.wait(seconds)
    _result
  }

  cancel: func () -> Void {
    //How to terminate thread?

    this _state = PromiseState Cancelled
  }

  _execute: override func {
    try {
      this _state = PromiseState Running

      this _thread = Thread new(||
        this _task()
      )

      this _thread start()
    } catch (e: Exception) {
      this _state = PromiseState Error
    }
  }
}
