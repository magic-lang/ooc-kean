use ooc-base
import include/[egl, gles]
import text/StringTokenizer
import structs/ArrayList

validateStart: func {
	validate("from unknown location")
}
validateEnd: func (location: String) {
	validate("in " + location)
}

validate: func (message: String) {
	glError := glGetError()
	if (glError != GL_NO_ERROR) {
		errorMessage := "OpenGL error " + message + ": " + getErrorMessage(glError)
		Debug print(errorMessage)
		raise(errorMessage)
	}
}
printGlError: func {
	Debug print("OpenGL error: " + getErrorMessage(glGetError()))
	Debug print("EGL error: " + eglGetError() toString())
}
getErrorMessage: func (errorCode: Int) -> String {
	result := match (errorCode) {
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
getExtensions: func -> String {
	result: CString = glGetString(GL_EXTENSIONS) as CString
	String new(result, result length())
}
getExtensionList: func -> ArrayList<String> {
	string := getExtensions()
	string split(' ')
}
queryExtension: func (extension: String) -> Bool {
	string := getExtensions()
	string contains?(extension)
}
printExtensions: func {
	array := getExtensionList()
	Debug print("OpenGL extensions:")
	for (i in 0 .. array size)
		Debug print(array[i])
}
printVersionInfo: func {
	vendor: CString = glGetString(GL_VENDOR) as CString
	renderer: CString = glGetString(GL_RENDERER) as CString
	version: CString = glGetString(GL_VERSION) as CString

	Debug print("OpenGL vendor: %s" format(vendor))
	Debug print("OpenGL renderer: %s" format(renderer))
	Debug print("OpenGL version: %s" format(version))
}
