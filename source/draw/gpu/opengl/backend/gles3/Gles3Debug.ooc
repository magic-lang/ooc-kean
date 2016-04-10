/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import ../egl/egl
import external/gles3

version(!gpuOff) {
validateStart: func (location: String) {
	validate("before " + location + " from unknown location")
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
	Debug print("EGL error: " + getEglErrorMessage(eglGetError()))
}
getErrorMessage: func (errorCode: Int) -> String {
	result := match (errorCode) {
		case 36054 => "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
		case 36055 => "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
		case 36056 => "GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS"
		case 1280 => "GL_INVALID_ENUM"
		case 1281 => "GL_INVALID_VALUE"
		case 1282 => "GL_INVALID_OPERATION"
		case 1286 => "GL_INVALID_FRAMEBUFFER_OPERATION"
		case => "ERROR CODE: " + errorCode toString()
	}
	result
}
getEglErrorMessage: func (errorCode: Int) -> String {
	result := match (errorCode) {
		case 12288 => "EGL_SUCCESS"
		case 12290 => "EGL_BAD_ACCESS"
		case 12291 => "EGL_BAD_ALLOC"
		case 12292 => "EGL_BAD_ATTRIBUTE"
		case 12294 => "EGL_BAD_CONTEXT"
		case 12297 => "EGL_BAD_MATCH"
		case 12300 => "EGL_BAD_PARAMETER"
		case 12301 => "EGL_BAD_SURFACE"
		case 12302 => "EGL_CONTEXT_LOST"
		case => "Unknown ERROR CODE: " + errorCode toString()
	}
	result
}
getExtensions: func -> String {
	result: CString = glGetString(GL_EXTENSIONS) as CString
	String new(result, result length())
}
getExtensionList: func -> VectorList<String> {
	string := getExtensions()
	string split(' ')
}
queryExtension: func (extension: String) -> Bool {
	string := getExtensions()
	string contains(extension)
}
printExtensions: func {
	array := getExtensionList()
	Debug print("OpenGL extensions:")
	for (i in 0 .. array count)
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
}
