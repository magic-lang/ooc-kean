/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

Synchronized: class {
	_lock: Mutex
	init: func (lock: Mutex) { this _lock = lock }
	init: func ~default { this init(Mutex new()) }
	free: override func {
		if (this _lock != null)
			this _lock free()
		this _lock = null
		super()
	}
	lock: func {
		this _lock lock()
	}
	unlock: func {
		this _lock unlock()
	}
	lock: func ~action (action: Func) {
		this lock()
		action()
		this unlock()
	}
	lockFunc: func <T> (function: Func -> T) -> T {
		this lock()
		result := function()
		this unlock()
		result
	}
}
