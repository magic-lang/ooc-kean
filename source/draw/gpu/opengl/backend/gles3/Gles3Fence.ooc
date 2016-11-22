/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import external/gles3
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
	clientWait: override func (timeout: ULong = ULong maximumValue) -> Bool {
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
		version(debugGL) { if (this _backend == null) Debug print("glFenceSync failed!") }
		version(debugGL) { validateEnd("Fence sync") }
	}
}
}
