import ../Thread
import native/win32/[types, errors]

version(windows) {
	include windows

	CreateMutex: extern func (Pointer, Bool, Pointer) -> Handle
	ReleaseMutex: extern func (Handle)
	CloseHandle: extern func (Handle)

	WaitForSingleObject: extern func (...) -> Long // laziness
	INFINITE: extern Long

	MutexWin32: class extends Mutex {
		_backend: Handle
		init: func {
			this _backend = CreateMutex (
				null, // default security attributes
				false, // initially not owned
				null) // unnamed mutex
		}
		free: override func {
			CloseHandle(this _backend)
			super()
		}
		lock: func {
			WaitForSingleObject(
				this _backend, // handle to mutex
				INFINITE // no time-out interval
			)
		}
		unlock: func {
			ReleaseMutex(this _backend)
		}
	}

	/**
	 * Win32 implementation of recursive mutexes.
	 *
	 * Apparently, Win32 mutexes are recursive by default, so this is just a
	 * copy of `MutexWin32`, which is by
	 */
	RecursiveMutexWin32: class extends RecursiveMutex {
		_backend: Handle
		init: func {
			this _backend = CreateMutex (
				null, // default security attributes
				false, // initially not owned
				null) // unnamed mutex
		}
		free: override func {
			CloseHandle(this _backend)
			super()
		}
		lock: func {
			WaitForSingleObject(
				this _backend, // handle to mutex
				INFINITE // no time-out interval
			)
		}
		unlock: func {
			ReleaseMutex(this _backend)
		}
	}
}
