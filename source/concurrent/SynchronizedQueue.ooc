/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use concurrent

SynchronizedQueue: class <T> extends Queue<T> {
	_mutex := Mutex new()
	_backend: Queue<T>
	count ::= this _backend count
	empty ::= this _backend empty
	init: func {
		super()
		this _backend = VectorQueue<T> new()
	}
	free: override func {
		(this _backend, this _mutex) free()
		super()
	}
	enqueue: override func (item: T) {
		this _mutex lock()
		this _backend enqueue(item)
		this _mutex unlock()
	}
	dequeue: override func ~default (fallback: T) -> T {
		this _mutex lock()
		result := this _backend dequeue(fallback)
		this _mutex unlock()
		result
	}
	peek: override func ~default (fallback: T) -> T {
		this _mutex lock()
		result := this _backend peek(fallback)
		this _mutex unlock()
		result
	}
	clear: override func {
		this _mutex lock()
		this _backend clear()
		this _mutex unlock()
	}
}

BlockedQueue: class <T> extends SynchronizedQueue<T> {
	_waitLock: WaitLock
	_canceled := false
	init: func {
		super()
		this _waitLock = WaitLock new(this _mutex)
	}
	free: override func {
		this _waitLock free()
		super()
	}
	enqueue: override func (item: T) {
		super(item)
		this _waitLock wake()
	}
	cancel: func { this _waitLock with(|| this _canceled = true) . wakeAll() }
	wait: func -> T {
		result: T = null
		this _waitLock lockWhen(func -> Bool { !this empty || this _canceled })
		if (!this _canceled)
			result = this _backend dequeue(result)
		this _waitLock unlock()
		result
	}
}
