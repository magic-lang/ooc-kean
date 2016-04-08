/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

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
		(this _free as Closure) free(Owner Receiver)
		super()
	}
	add: func (object: T) {
		if (this isFull)
			this _free(this _list remove(0))
		this _list add(object)
	}
	search: func (matches: Func (T) -> Bool) -> T {
		index := this _list search(matches)
		result: T = null
		(index > -1) ? this _list remove(index) : result
	}
	clear: func {
		while (!this isEmpty)
			this _free(this _list remove())
	}
}
