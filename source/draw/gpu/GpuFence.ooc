version(!gpuOff) {
GpuFence: abstract class {
	init: func
	wait: abstract func -> Bool
	gpuWait: abstract func
	sync: abstract func
}
}
