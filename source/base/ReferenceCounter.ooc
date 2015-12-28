import threading/Mutex
import Synchronized

ReferenceCounter: class {
	_target: Object
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
	}
	free: override func {
		This count -= 1
		this _lock free()
		super()
	}
	update: func (delta: Int) {
		if (delta != 0) {
			this _lock lock()
			target := null
			if (!this _kill) {
				this _count += delta
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
	increase: func { this update(1) }
	decrease: func { this update(-1) }
	toString: func -> String { "Object ID: " << this _target as Pointer toString() >> " Count: " & this _count toString() }

	count: static Int = 0
}
