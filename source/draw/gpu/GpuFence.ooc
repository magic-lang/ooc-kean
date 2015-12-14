version(!gpuOff) {
GpuFence: abstract class {
	init: func
	wait: abstract func -> Bool
	wait: abstract func ~timeout (nanoseconds: UInt64) -> Bool
	gpuWait: abstract func
	sync: abstract func
}
}
