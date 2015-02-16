use ooc-base
import include/gles
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
		DebugPrint print(errorMessage)
		raise(errorMessage)
	}
}
