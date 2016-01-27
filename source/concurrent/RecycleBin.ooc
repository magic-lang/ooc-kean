/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import threading/Mutex

RecycleBin: class <T> {
	_mutex := Mutex new()
	_free: Func (T)
	//TODO: Replace with SynchronizedList
	_list: VectorList<T>
	_size: Int
	count ::= this _list count
	isFull ::= this count == this _size
	isEmpty ::= this _list empty
	init: func (=_size, =_free) { this _list = VectorList<T> new(_size) }
	free: override func {
		this clear()
		this _list free()
		this _mutex free()
		super()
	}
	add: func (object: T) {
		this _mutex lock()
		if (this isFull)
			this _free(this _list remove(0))
		this _list add(object)
		this _mutex unlock()
	}
	search: func (matches: Func (T) -> Bool) -> T {
		result: T = null
		this _mutex lock()
		for (i in 0 .. this _list count) {
			if (matches(this _list[i])) {
				result = this _list remove(i)
				break
			}
		}
		this _mutex unlock()
		(matches as Closure) free()
		result
	}
	clear: func {
		this _mutex lock()
		while (!this isEmpty)
			this _free(this _list remove())
		this _mutex unlock()
	}
}
/*
use concurrent

RecycleBin: class <T> {
	_free: Func (T)
	_list: SynchronizedList<T>
	_size: Int
	count ::= this _list count
	isFull ::= this count == this _size
	isEmpty ::= this _list empty
	init: func (=_size, =_free) { this _list = SynchronizedList<T> new(_size) }
	free: override func {
		this clear()
		this _list free()
		super()
	}
	add: func (object: T) {
		if (this isFull)
			this _free(this _list remove(0))
		this _list add(object)
	}
	search: func (matches: Func (T) -> Bool) -> T {
		result: T = null
		for (i in 0 .. this _list count) {
			if (matches(this _list[i])) {
				result = this _list remove(i)
				break
			}
		}
		(matches as Closure) free()
		result
	}
	clear: func {
		while (!this isEmpty)
			this _free(this _list remove())
	}
}*/
