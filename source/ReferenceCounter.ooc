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
<<<<<<< HEAD
				this _target free()
				this unlock()
				this free()
=======
				this _target dispose()
				this unlock()
				this dispose()
>>>>>>> 6657b0ea467138aeeb4c8dbf476c581e117d99f5
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
