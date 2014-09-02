import threading/Thread
import Synchronized

ReferenceCounter: class extends Synchronized {
	_target: Object
	_count: Int
	_claimed := true
	_claimLock := Mutex new()
	claimed: Bool {
		get {
			this _claimed
// TODO: implement with lock
		}
	}
	_reuse: Func(Object)
	reuse: Func(Object) {
		set (value) {
// TODO: implement with lock
			if ((this _reuse as Closure) thunk == null) // this _reuse == null
				this _reuse = value
		}
	}
	init: func (=_target)
	update: func (delta: Int) {
		if (delta != 0) {
//			TODO: implement with lock
			this _count += delta
			if (this _count <= 0) {
				if ((this _reuse as Closure) thunk != null) { // this _reuse != null
					this _count = 0
					this _reuse(this _target)
				}
//				else if (this _target instanceOf?(IDisposable))
//					(this _target as IDisposable) dispose()
			}
		}
	}
	increase: func { this update(1) }
	decrease: func { this update(-1) }
//	claim: Bool {
		// TODO: use claimLock
//		return true
//	}
	toString: func { this _count toString() }
}
