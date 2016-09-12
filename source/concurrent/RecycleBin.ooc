/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use concurrent

RecycleBin: class <T> {
	_free: Func (T)
	_list: VectorList<T>
	_size: Int
	count ::= this _list count
	isFull ::= this count == this _size
	isEmpty ::= this _list empty
	_mutex := Mutex new()
	init: func (=_size, =_free) { this _list = VectorList<T> new(_size) }
	free: override func {
		this clear()
		this _list free()
		(this _free as Closure) free(Owner Receiver)
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
		this _mutex lock()
		index := this _list search(matches)
		result: T = null
		if (index > -1)
			result = this _list remove(index)
		this _mutex unlock()
		result
	}
	clear: func {
		this _mutex lock()
		while (!this isEmpty)
			this _free(this _list remove())
		this _mutex unlock()
	}
}
