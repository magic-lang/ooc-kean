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
import include/gles3
import ../GLFence
import threading/Thread
import Gles3Debug

Gles3Fence: class extends GLFence {
	init: func { super() }
	free: override func {
		version(debugGL) { validateStart() }
		glDeleteSync(this _backend)
		version(debugGL) { validateEnd("Fence free") }
		super()
	}
	clientWait: func (timeout: UInt64 = ULLONG_MAX) {
		version(debugGL) { validateStart() }
		this _mutex lock()
		if (this _backend == null)
			this _syncCondition wait(this _mutex)
		this _mutex unlock()
		version(debugGL) {
			result := glClientWaitSync(this _backend, GL_SYNC_FLUSH_COMMANDS_BIT, timeout)
			match (result) {
				case GL_TIMEOUT_EXPIRED => Debug print("Fence reached timeout limit after %llu ns. Possible deadlock?" format(timeout))
				case GL_WAIT_FAILED => Debug print("Fence wait failed!")
				/*
				case GL_ALREADY_SIGNALED => Debug print("Fence has already been signaled!")
				case GL_CONDITION_SATISFIED => Debug print("Fence condition satisifed!")
				*/
			}
		} else
			glClientWaitSync(this _backend, GL_SYNC_FLUSH_COMMANDS_BIT, timeout)
		version(debugGL) { validateEnd("Fence clientWait") }
	}
	wait: func {
		version(debugGL) { validateStart() }
		glFlush()
		glWaitSync(this _backend, 0, GL_TIMEOUT_IGNORED)
		version(debugGL) { validateEnd("Fence wait") }
	}
	sync: func {
		version(debugGL) { validateStart() }
		this _mutex lock()
		if (this _backend != null)
			glDeleteSync(this _backend)
		this _backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
		version(debugGL) { if (this _backend as Int == 0) Debug print("glFenceSync failed!") }
		this _mutex unlock()
		this _syncCondition broadcast()
		glFlush()
		version(debugGL) { validateEnd("Fence sync") }
	}
}
