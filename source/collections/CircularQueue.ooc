/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import VectorQueue

CircularQueue: class <T> extends Queue<T> {
	_backend: VectorQueue<T>
	_cleanupCallback: Func (T)
	_maximumCapacity: Int
	count ::= this _backend count
	capacity ::= this _backend capacity
	isFull ::= this _backend isFull

	init: func ~defaultCallback (capacity: Int) {
		callback: Func (T)
		if (T inheritsFrom(Object))
			callback = func (t : T) {
				if (t != null)
					(t as Object) free()
			}
		else
			callback = func (t: T)
		this init(capacity, callback)
	}
	init: func (=_maximumCapacity, =_cleanupCallback) {
		this _backend = VectorQueue<T> new(this _maximumCapacity)
	}
	free: override func {
		this clear()
		this _backend free()
		(this _cleanupCallback as Closure) free(Owner Receiver)
		super()
	}
	clear: override func {
		while (this count > 0)
			this _cleanupCallback(this dequeue(null))
		this _backend clear()
	}
	enqueue: override func (item: T) {
		while (this count >= this _maximumCapacity)
			this _cleanupCallback(this dequeue(null))
		this _backend enqueue(item)
	}
	dequeue: override func ~default (fallback: T) -> T { this _backend dequeue(fallback) }
	peek: override func ~default (fallback: T) -> T { this _backend peek(fallback) }
	operator [] (index: Int) -> T { this _backend[index] }
	operator []= (index: Int, value: T) { this _backend[index] = value }
}
