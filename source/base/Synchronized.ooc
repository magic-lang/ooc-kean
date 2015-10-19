/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/
import threading/Thread
Synchronized: class {
	_lock: Mutex
	init: func (lock: Mutex) { this _lock = lock }
	init: func ~default { this init(Mutex new()) }
	free: override func {
		if (this _lock != null)
			this _lock free()
		this _lock = null
//		this _lock free()
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
		result: T
		this lock()
		try {
			result = function()
			this unlock()
		} catch (e: Exception) {
			this unlock()
			e throw()
		}
		result
	}
}
