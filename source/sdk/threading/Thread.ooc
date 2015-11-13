import native/[ThreadUnix, ThreadWin32]
import native/[MutexUnix, MutexWin32]
import native/[ThreadLocalUnix, ThreadLocalWin32]
import native/[ConditionUnix, ConditionWin32]

Thread: abstract class {
	_code: Func

	new: static func (._code) -> This {
		version (unix || apple) {
			return ThreadUnix new(_code) as This
		}
		version (windows) {
			return ThreadWin32 new(_code) as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	start: abstract func -> Bool

	wait: abstract func -> Bool

	wait: abstract func ~timed (seconds: Double) -> Bool

	cancel: abstract func -> Bool

	alive?: abstract func -> Bool

	currentThread: static func -> This {
		version (unix || apple) {
			return ThreadUnix _currentThread()
		}
		version (windows) {
			return ThreadWin32 _currentThread()
		}
		null
	}

	yield: static func -> Bool {
		version (unix || apple) {
			return ThreadUnix _yield()
		}
		version (windows) {
			return ThreadWin32 _yield()
		}
		false
	}
}

MutexType: enum {
	Safe,
	Unsafe,
	Global
}

Mutex: abstract class {
	new: static func (mutexType := MutexType Safe) -> This {
		result: This
		match (mutexType) {
			case MutexType Safe => {
				version (unix || apple)
					result = MutexUnix new()
				version (windows)
					result = MutexWin32 new()
				if (result == null)
					Exception new(This, "Unsupported platform!\n") throw()
			}
			case MutexType Unsafe =>
				result = MutexUnsafe new()
			case =>
				result = MutexGlobal new()
		}
		result
	}

	lock: abstract func

	unlock: abstract func

	with: func (f: Func) {
		lock()
		f()
		unlock()
	}
}

MutexUnsafe: class extends Mutex {
	init: func
	lock: override func
	unlock: override func
}

MutexGlobal: class extends Mutex {
	_globalMutex := static Mutex new(MutexType Safe)
	init: func
	lock: override func {
		This _globalMutex lock()
	}
	unlock: override func {
		This _globalMutex unlock()
	}
	cleanup: static func {
		This _globalMutex free()
	}
}

// A recursive mutex can be locked several times in a row. unlock() should be called as many times to properly unlock it
RecursiveMutex: abstract class extends Mutex {
	new: static func -> This {
		version (unix || apple) {
			return RecursiveMutexUnix new()
		}
		version (windows) {
			return RecursiveMutexWin32 new()
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	lock: abstract func

	unlock: abstract func

	with: func (f: Func) {
		lock()
		f()
		unlock()
	}
}

/**
 * A ThreadLocal is a variable whose data is not shared by all threads
 * (as it is for normal global variables), but each thread has got
 * its own storage.
 */
ThreadLocal: abstract class <T> {
	new: static func <T> -> This<T> {
		version (unix || apple) {
			return ThreadLocalUnix<T> new() as This
		}
		version (windows) {
			return ThreadLocalWin32<T> new() as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	new: static func ~withVal <T> (val: T) -> This <T> {
		instance := This<T> new()
		instance set(val)
		instance
	}

	set: abstract func (value: T)

	get: abstract func -> T

	hasValue?: abstract func -> Bool
}

WaitCondition: abstract class {
	new: static func -> This {
		version (unix || apple) {
			return ConditionUnix new() as This
		}
		version (windows) {
			return ConditionWin32 new() as This
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}

	wait: abstract func (mutex: Mutex) -> Bool

	signal: abstract func -> Bool

	broadcast: abstract func -> Bool
}
