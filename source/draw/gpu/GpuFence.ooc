version(!gpuOff) {
GpuFence: abstract class {
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~timeout (nanoseconds: ULong) -> Bool
	gpuWait: abstract func
	sync: abstract func
}
}
