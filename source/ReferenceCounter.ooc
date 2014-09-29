import threading/Thread
import Synchronized

ReferenceCounter: class extends Synchronized {
	_target: Object
	_count: Int
	init: func (target: Object) {
		super()
		this _target = target
	}
	update: func (delta: Int) {
		if (delta != 0) {
			this lock()
			this _count += delta
			if (this _count <= 0) {
				this _target free()
				this unlock()
				this free()
//				free(this)
			}
			else
				this unlock()
		}
	}
	increase: func { this update(1) }
	decrease: func { this update(-1) }
	toString: func -> String { this _count toString() }
//	dispose: func { free(this _lock) }
}
