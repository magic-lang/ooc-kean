use ooc-draw-gpu
import OpenGLES3/Fence

OpenGLES3Fence: class extends GpuFence {
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
