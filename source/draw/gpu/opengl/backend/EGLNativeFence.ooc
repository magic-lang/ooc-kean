import egl/egl
import GLExtensions
EGLNativeFence: class {
	_backend: Pointer
	_display: Pointer
	init: func (=_display) {
		this _backend = GLExtensions eglCreateSyncKHR(this _display, EGL_SYNC_NATIVE_FENCE_ANDROID, null as Int*)
	}
	free: override func {
		GLExtensions eglDestroySyncKHR(this _display, this _backend)
		super()
	}
	duplicateFileDescriptor: func -> Int { GLExtensions eglDupNativeFenceFDANDROID(this _display, this _backend) }
}