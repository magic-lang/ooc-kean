import egl/egl
import GLExtensions, GLFence
EGLNativeFence: class extends GLFence {
	_display: Pointer
	init: func (=_display) { super() }
	free: override func {
		GLExtensions eglDestroySyncKHR(this _display, this _backend)
		super()
	}
	sync: override func {
		this _backend = GLExtensions eglCreateSyncKHR(this _display, EGL_SYNC_NATIVE_FENCE_ANDROID, null as Int*)
	}
	clientWait: override func (timeout: ULong = ULong maximumValue) -> Bool {
		GLExtensions eglClientWaitSyncKHR(this _display, this _backend, EGL_SYNC_FLUSH_COMMANDS_BIT_KHR, timeout)
	}
	wait: override func { raise("Wait unimplemented for EGLNativeFence") }
	duplicateFileDescriptor: func -> Int { GLExtensions eglDupNativeFenceFDANDROID(this _display, this _backend) }
}
