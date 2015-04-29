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
		errorMessage := "OpenGL error " + message + ": "  + getErrorMessage(glError)
		Debug print(errorMessage)
		raise(errorMessage)
	}
}
printGlError: func {
	Debug print("OpenGL error: " + getErrorMessage(glGetError()))
	Debug print("EGL error: " + eglGetError() toString())
}
getErrorMessage: func (errorCode: Int) -> String {
	result := match(errorCode) {
		case 36054 => "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
		case 36055 => "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
		case 36056 => "GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS"
		case 1280 => "GL_INVALID_ENUM"
		case 1281 => "GL_INVALID_VALUE"
		case 1282 => "GL_INVALID_OPERATION"
		case => "ERROR CODE: " + errorCode toString()
	}
	result
}
