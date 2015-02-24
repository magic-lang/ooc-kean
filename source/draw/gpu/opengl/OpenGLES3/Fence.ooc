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
import os/Time
import include/gles
import threading/native/ConditionUnix
import threading/Thread
Fence: class {
	_backend: Pointer = null
	_syncCondition: ConditionUnix
	_mutex: Mutex
	init: func {
		this _mutex = Mutex new()
		this _syncCondition = ConditionUnix new()
	}
	clientWait: func (timeout: UInt = GL_TIMEOUT_IGNORED) {
		this _mutex lock()
		if (this _backend == null)
			this _syncCondition wait(this _mutex)
		this _mutex unlock()
		result := glClientWaitSync(this _backend, GL_SYNC_FLUSH_COMMANDS_BIT, timeout)
		version(debugGL) {
			match (result) {
				case GL_TIMEOUT_EXPIRED => DebugPrint print("Fence reached timeout limit. Possible deadlock?")
				case GL_WAIT_FAILED => DebugPrint print("Fence wait failed!")
				/*
				case GL_ALREADY_SIGNALED => DebugPrint print("Fence has already been signaled!")
				case GL_CONDITION_SATISFIED => DebugPrint print("Fence condition satisifed!")
				*/
			}
		}
	}
	wait: func {
		glFlush()
		glWaitSync(this _backend, 0, GL_TIMEOUT_IGNORED)
	}
	sync: func {
		this _mutex lock()
		if(this _backend != null)
			glDeleteSync(this _backend)
		this _backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
		version(debugGL) { if (this _backend as Int == 0) DebugPrint print("glFenceSync failed!") }
		this _mutex unlock()
		this _syncCondition broadcast()
		glFlush()
	}
	free: func {
		glDeleteSync(this _backend)
		this _mutex destroy()
		this _syncCondition destroy()
		super()
	}

}
