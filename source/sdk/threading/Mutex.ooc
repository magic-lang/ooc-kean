import native/[MutexUnix, MutexWin32]

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