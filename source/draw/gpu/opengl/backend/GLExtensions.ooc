import egl/egl

GLExtensions: class {
	eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	eglDestroyImageKHR: static Func(Pointer, Pointer)
	glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	initialize: static func {
		if (!This _initialized) {
			This eglCreateImageKHR = (eglGetProcAddress("eglCreateImageKHR" toCString()), null) as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This eglDestroyImageKHR = (eglGetProcAddress("eglDestroyImageKHR" toCString()), null) as Func(Pointer, Pointer)
			This glEGLImageTargetTexture2DOES = (eglGetProcAddress("glEGLImageTargetTexture2DOES" toCString()), null) as Func(UInt, Pointer)
			This _initialized = true
		}
	}
	_initialized := static false
}