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

use ooc-base
use ooc-math
import os/Time
import threading/native/ConditionUnix
import threading/Thread

GLFence: abstract class {
	_backend: Pointer = null
	_syncCondition := ConditionUnix new()
	_mutex := Mutex new()

	init: func
	free: override func {
		this _mutex destroy()
		this _syncCondition free()
		super()
	}
	clientWait: abstract func (timeout: UInt64 = ULLONG_MAX)
	wait: abstract func
	sync: abstract func
}
