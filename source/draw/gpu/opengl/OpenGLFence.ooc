//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

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
	wait: override func ~timeout (nanoseconds: UInt64) -> Bool {
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
