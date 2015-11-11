import threading/Thread
import Synchronized

ReferenceCounter: class {
	_target: Object
	count: static Int = 0
	_count: Int = 0
	_kill := false
	_lock: Mutex
	isSafe: Bool {
		get { !this _lock instanceOf?(MutexUnsafe) }
		set(value) {
			if (this isSafe != value) {
				this _lock free()
				this _lock = Mutex new(value ? MutexType Safe : MutexType Unsafe)
			}
		}
	}
	init: func (target: Object, mutexType := MutexType Safe) {
		This count += 1
		this _target = target
		this _lock = Mutex new(mutexType)
//		"  RC, #{This count}, #{this _target class name}" println()
	}
	update: func (delta: Int) {
		if (delta != 0) {
			this _lock lock()
			target := null
			if (!this _kill) {
				this _count += delta
//				("{" + _target class name + "} #{this} #{delta}") println()
				this _kill = this _count <= 0
				if (this _kill)
					target = this _target
			}
			this _lock unlock()
			if (target != null) {
				this _count = 0
				this _kill = false
				target free()
			}
		}
	}
	free: override func {
		This count -= 1
//		"--RC, #{This count}, #{this _target class name}" println()
		this _lock free()
		super()
	}
	increase: func { this update(1) }
	decrease: func { this update(-1) }
	toString: func -> String { "Object ID: " << this _target as Pointer toString() >> " Count: " & this _count toString() }
}
