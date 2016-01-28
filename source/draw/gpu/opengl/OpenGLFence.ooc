/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw-gpu
import backend/[GLFence, GLContext]
import OpenGLContext
import threading/[Mutex, WaitCondition]

version(!gpuOff) {
OpenGLFence: class extends GpuFence {
	_backend: GLFence
	_syncCondition := WaitCondition new()
	_mutex := Mutex new()
	_context: OpenGLContext
	init: func (=_context)
	free: override func {
		this _mutex free()
		this _syncCondition free()
		this _backend free()
		super()
	}
	wait: override func -> Bool { this wait(ULLONG_MAX) }
	wait: override func ~timeout (nanoseconds: ULong) -> Bool {
		this _mutex lock()
		if (this _backend == null)
			this _syncCondition wait(this _mutex)
		if (this _backend == null)
			raise("OpenGLFence: _backend is still null after waiting on _syncCondition")
		result := this _backend clientWait(nanoseconds)
		this _mutex unlock()
		result
	}
	gpuWait: override func { this _backend wait() }
	sync: override func {
		this _mutex lock()
		if (this _backend != null)
			this _backend free()
		this _backend = this _context backend as GLContext createFence()
		this _backend sync()
		this _syncCondition broadcast()
		this _mutex unlock()
	}
}
}
