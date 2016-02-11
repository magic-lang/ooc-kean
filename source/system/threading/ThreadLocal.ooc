/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Thread
import Mutex

ThreadLocal: class <T> {
	_values := HashMap<ThreadId, T> new()
	_mutex := Mutex new()
	init: func
	set: func (value: T) {
		this _mutex lock()
		this _values put(Thread currentThreadId(), value)
		this _mutex unlock()
	}
	get: func -> T {
		this _mutex lock()
		value := this _values get(Thread currentThreadId())
		this _mutex unlock()
		value
	}
	hasValue: func -> Bool {
		this _mutex lock()
		result := this _values contains(Thread currentThreadId())
		this _mutex unlock()
		result
	}
	free: override func {
		this _values free()
		this _mutex free()
	}
}
