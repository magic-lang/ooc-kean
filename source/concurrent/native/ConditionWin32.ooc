/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(windows) {
use base
import ../[WaitCondition, Thread]

ConditionWin32: class extends WaitCondition {
	_mutex := Mutex new()
	_waitingEvents := VectorList<Handle> new()
	_waitingForRelease := VectorList<Handle> new()
	init: func
	// do not destroy wait condition while threads are still waiting on it
	free: override func {
		this _mutex lock()
		//waiting threads should have a chance to wake up
		for (i in 0 .. this _waitingEvents count) {
			SetEvent(this _waitingEvents[i])
			Thread yield()
		}
		for (i in 0 .. this _waitingForRelease count)
			CloseHandle(this _waitingForRelease[i])
		for (i in 0 .. this _waitingEvents count)
			CloseHandle(this _waitingEvents[i])
		this _mutex unlock()
		(this _waitingEvents, this _waitingForRelease, this _mutex) free()
		super()
	}
	wait: override func (mutex: Mutex) -> Bool {
		eventId := CreateEvent(null, false, false, null)
		this _mutex lock()
		this _waitingEvents add(eventId)
		this _mutex unlock()
		mutex unlock()
		(WaitForSingleObject(eventId, INFINITE) == WaitSuccess)
	}
	signal: override func -> Bool {
		result := false
		toSignal := 0 as Handle
		this _mutex lock()
		if (this _waitingEvents count > 0) {
			toSignal = this _waitingEvents remove(0)
			this _waitingForRelease add(toSignal)
		}
		this _mutex unlock()
		if (toSignal != 0)
			result = SetEvent(toSignal)
		result
	}
	broadcast: override func -> Bool {
		result := false
		toSignal := VectorList<Handle> new()
		this _mutex lock()
		while (this _waitingEvents count > 0) {
			eventId := this _waitingEvents remove(0)
			this _waitingForRelease add(eventId)
			toSignal add(eventId)
		}
		this _mutex unlock()
		if (toSignal count > 0) {
			result = true
			for (i in 0 .. toSignal count)
				result = result && SetEvent(toSignal[i])
		}
		toSignal free()
		result
	}
}
}
