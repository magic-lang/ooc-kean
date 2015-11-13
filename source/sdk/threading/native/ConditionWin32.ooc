version(windows) {
	import ../Thread
	import native/win32/[types, errors]
	import MutexWin32
	import structs/ArrayList

	include windows

	CreateEvent: extern func (...) -> Handle
	SetEvent: extern func (Handle) -> Bool
	CloseHandle: extern func (Handle) -> Bool
	Infinite: extern (INFINITE) Long
	WaitSuccess: extern (WAIT_OBJECT_0) Long

	ConditionWin32: class extends WaitCondition {
		_mutex := Mutex new()
		_waitingEvents := ArrayList<Handle> new()
		_waitingForRelease := ArrayList<Handle> new()
		init: func
		// do not destroy wait condition while threads are still waiting on it
		free: override func {
			this _mutex lock()
			//waiting threads should have a chance to wake up
			for (i in 0 .. this _waitingEvents size) {
				SetEvent(this _waitingEvents[i])
				Thread yield()
			}
			for (i in 0 .. this _waitingForRelease size)
				CloseHandle(this _waitingForRelease[i])
			for (i in 0 .. this _waitingEvents size)
				CloseHandle(this _waitingEvents[i])
			this _mutex unlock()
			this _waitingEvents free()
			this _waitingForRelease free()
			this _mutex free()
			super()
		}
		wait: func (mutex: Mutex) -> Bool {
			eventId := CreateEvent(null, false, false, null)
			this _mutex lock()
			this _waitingEvents add(eventId)
			this _mutex unlock()
			mutex unlock()
			(WaitForSingleObject(eventId, Infinite) == WaitSuccess)
		}
		signal: func -> Bool {
			result := false
			toSignal := 0 as Handle
			this _mutex lock()
			if (this _waitingEvents size > 0) {
				toSignal = this _waitingEvents first()
				this _waitingEvents removeAt(0)
				this _waitingForRelease add(toSignal)
			}
			this _mutex unlock()
			if (toSignal != 0)
				result = SetEvent(toSignal)
			result
		}
		broadcast: func -> Bool {
			result := false
			toSignal := ArrayList<Handle> new()
			this _mutex lock()
			while (this _waitingEvents size > 0) {
				eventId := this _waitingEvents first()
				this _waitingEvents removeAt(0)
				this _waitingForRelease add(eventId)
				toSignal add(eventId)
			}
			this _mutex unlock()
			if (toSignal size > 0) {
				result = true
				for (i in 0 .. toSignal size)
					result = result && SetEvent(toSignal[i])
			}
			toSignal free()
			result
		}
	}
}
