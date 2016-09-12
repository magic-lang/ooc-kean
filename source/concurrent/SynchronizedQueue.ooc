/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
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
	operator [] (index: Int) -> T {
		this _mutex lock()
		result := this _backend[index]
		this _mutex unlock()
		result
	}
	operator []= (index: Int, value: T) {
		this _mutex lock()
		this _backend[index] = value
		this _mutex unlock()
	}
}

BlockedQueue: class <T> extends SynchronizedQueue<T> {
	_waitLock: WaitLock
	_canceled := false
	_lockFunc: Func -> Bool
	init: func {
		super()
		this _waitLock = WaitLock new(this _mutex)
		this _lockFunc = func -> Bool { !this empty || this _canceled }
		this _lockFunc = ((this _lockFunc as Closure) take()) as Func -> Bool
	}
	free: override func {
		this _waitLock free()
		(this _lockFunc as Closure) give() free()
		super()
	}
	enqueue: override func (item: T) {
		super(item)
		this _waitLock wake()
	}
	cancel: func { this _waitLock with(|| this _canceled = true) . wakeAll() }
	wait: func -> T {
		this _waitLock lockWhen(this _lockFunc)
		result: T = null
		if (!this _canceled)
			result = this _backend dequeue(result)
		this _waitLock unlock()
		result
	}
}
