use base
import egl/egl

GLExtensions: class {
	eglCreateImageKHR: static Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
	eglDestroyImageKHR: static Func(Pointer, Pointer)
	glEGLImageTargetTexture2DOES: static Func(UInt, Pointer)
	initialize: static func {
		if (!This _initialized) {
			This eglCreateImageKHR = This _load("eglCreateImageKHR") as Func(Pointer, Pointer, UInt, Pointer, Int*) -> Pointer
			This eglDestroyImageKHR = This _load("eglDestroyImageKHR") as Func(Pointer, Pointer)
			This glEGLImageTargetTexture2DOES = This _load("glEGLImageTargetTexture2DOES") as Func(UInt, Pointer)
			This _initialized = true
		}
	}
	_load: static func (name: String) -> (Pointer, Pointer) {
		result := eglGetProcAddress(name toCString())
		if (result == null)
			Debug print("Failed to load OpenGL extension function: " + name)
		(result, null)
	}
	_initialized := static false
}