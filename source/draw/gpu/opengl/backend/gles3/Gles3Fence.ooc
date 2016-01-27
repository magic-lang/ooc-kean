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

use base
import include/gles3
import ../GLFence
import Gles3Debug

version(!gpuOff) {
Gles3Fence: class extends GLFence {
	init: func { super() }
	free: override func {
		version(debugGL) { validateStart("Fence free") }
		glDeleteSync(this _backend)
		version(debugGL) { validateEnd("Fence free") }
		super()
	}
	clientWait: override func (timeout: ULong = ULONG_MAX) -> Bool {
		version(debugGL) { validateStart("Fence clientWait") }
		code := glClientWaitSync(this _backend, GL_SYNC_FLUSH_COMMANDS_BIT, timeout)
		version(debugGL) {
			match (code) {
				case GL_TIMEOUT_EXPIRED => Debug print("Fence reached timeout limit after %llu ns. Possible deadlock?" format(timeout))
				case GL_WAIT_FAILED => Debug print("Fence wait failed!")
				/*
				case GL_ALREADY_SIGNALED => Debug print("Fence has already been signaled!")
				case GL_CONDITION_SATISFIED => Debug print("Fence condition satisifed!")
				*/
			}
		}
		version(debugGL) { validateEnd("Fence clientWait") }
		code == GL_CONDITION_SATISFIED || code == GL_ALREADY_SIGNALED
	}
	wait: override func {
		version(debugGL) { validateStart("Fence wait") }
		glWaitSync(this _backend, 0, GL_TIMEOUT_IGNORED)
		glFlush()
		version(debugGL) { validateEnd("Fence wait") }
	}
	sync: override func {
		version(debugGL) { validateStart("Fence sync") }
		if (this _backend != null)
			glDeleteSync(this _backend)
		this _backend = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)
		version(debugGL) { if (this _backend as Int == 0) Debug print("glFenceSync failed!") }
		version(debugGL) { validateEnd("Fence sync") }
	}
}
}
