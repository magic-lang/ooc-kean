use ooc-draw-gpu
import backend/gles3/Fence

OpenGLFence: class extends GpuFence {
	_backend := Fence new()
	init: func
	free: override func {
		this _backend free()
		super()
	}
	wait: func { this _backend clientWait() }
	gpuWait: func { this _backend wait() }
	sync: func { this _backend sync() }
}
