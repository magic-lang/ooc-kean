use ooc-draw-gpu
import backend/[GLFence, GLContext]
import OpenGLContext

OpenGLFence: class extends GpuFence {
	_backend: GLFence
	init: func (context: OpenGLContext) {
		_backend = context as GLContext createFence()
	}
	free: override func {
		this _backend free()
		super()
	}
	wait: func { this _backend clientWait() }
	gpuWait: func { this _backend wait() }
	sync: func { this _backend sync() }
}
