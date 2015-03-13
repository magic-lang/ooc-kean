use ooc-base
import include/[egl, gles]

validateStart: func {
	validate("from unknown location")
}
validateEnd: func (location: String) {
	validate("in " + location)
}

validate: func (message: String) {
	glError := glGetError()
	if(glError != GL_NO_ERROR) {
		errorMessage := "OpenGL error " + message + ": #"  + glError toString()
		Debug print(errorMessage)
		raise(errorMessage)
	}
}
printGlError: func {
	Debug print("OpenGL error: " + glGetError() toString())
	Debug print("EGL error: " + eglGetError() toString())
}
