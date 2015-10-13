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

use ooc-draw-gpu
import backend/[GLFence, GLContext]
import OpenGLContext

version(!gpuOff) {
OpenGLFence: class extends GpuFence {
	_backend: GLFence
	init: func (context: OpenGLContext) {
		this _backend = context backend as GLContext createFence()
	}
	free: override func {
		this _backend free()
		super()
	}
	wait: func { this _backend clientWait() }
	gpuWait: func { this _backend wait() }
	sync: func { this _backend sync() }
}
}
