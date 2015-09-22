/*
- abstrakt klass
+ wait
+
+ isDone()?
+ state
*/

PromiseResult: enum {
  RUNNING
	FINISHED
  CANCELLED
  ERROR
}

//TODO abstract?
Promise: class <T> {
  _result: T
  _state: PromiseResult
  _task: Func

  state ::= this _state
  result ::= this _result

  init: func(= _task) {
    this _execute()
  }

  wait: func() -> Void {
    while (this _state == PromiseResult RUNNING) {}
  }

  // Missing: wait with timeout

  /*getState: func() -> PromiseResult {

   }*/

  //TODO parallelize
  _execute: func {
    try {
      this _result = this _task()
      this _state = PromiseResult FINISHED
    } catch (e: Exception) {
      this _state = PromiseResult ERROR
    }
  }


}
