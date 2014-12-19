import threading/Thread
import Synchronized

ReferenceCounter: class extends Synchronized {
	_target: Object
	_count: Int = 0
	_kill := false
	init: func (target: Object) {
		super()
		this _target = target
	}
	update: func (delta: Int) {
		if (delta != 0) {
			this lock()
			target := null
			if (!this _kill) {
				this _count += delta
				("{" + _target class name + "} #{this} #{delta}") println()
				this _kill = this _count <= 0
				if (this _kill)
					target = this _target
			}
			this unlock()
			if (target != null) {
				this _count = 0
				this _kill = false
				target free()
			}
		}
	}
	increase: func { this update(1) }
	decrease: func { this update(-1) }
	toString: func -> String { "Object ID: " + this _target as Pointer toString() + " Count: " + this _count toString() }
}
