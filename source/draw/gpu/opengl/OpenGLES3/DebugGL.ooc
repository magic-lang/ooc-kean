use ooc-base
import include/[egl, gles]
printGlError: func {
	DebugPrint print("OpenGL error: " + glGetError() toString())
	DebugPrint print("EGL error: " + eglGetError() toString())
}
