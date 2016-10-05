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
getErrorMessage: func (errorCode: Int) -> String {
	result := match (errorCode) {
		case 36054 => "GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT"
		case 36055 => "GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT"
		case 36056 => "GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS"
		case 1280 => "GL_INVALID_ENUM"
		case 1281 => "GL_INVALID_VALUE"
		case 1282 => "GL_INVALID_OPERATION"
		case 1286 => "GL_INVALID_FRAMEBUFFER_OPERATION"
		case => "ERROR CODE: " & errorCode toString()
	}
	result
}

version(debugGL) {
validateStart: func (location: String) {
	if (eglGetCurrentContext() == EGL_NO_CONTEXT)
		Debug error("Calling OpenGL function outside of valid context in %s" format(location))
	validate("before %s from unknown location" format(location))
}
validateEnd: func (location: String) {
	validate("in %s" format(location))
}
validateEnd: func ~free (location: String) {
	validateEnd(location)
	location free()
}
validate: func (message: String) {
	glError := glGetError()
	if (glError != GL_NO_ERROR)
		Debug error("OpenGL error %s: %s" format(message, getErrorMessage(glError)))
	eglError := eglGetError()
	if (eglError != EGL_SUCCESS)
		Debug error("EGL error %s: %s" format(message, getEglErrorMessage(eglError)))
	message free()
}
printGlError: func {
	Debug print~free("OpenGL error: %s" format(getErrorMessage(glGetError())))
	Debug print~free("EGL error: %s" format(getEglErrorMessage(eglGetError())))
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
		case => "Unknown ERROR CODE: " & errorCode toString()
	}
	result
}
getExtensions: func -> String {
	result: CString = glGetString(GL_EXTENSIONS) as CString
	String new(result, result length())
}
getExtensionList: func -> VectorList<String> {
	string := getExtensions()
	result := string split(' ')
	string free()
	result
}
queryExtension: func (extension: String) -> Bool {
	string := getExtensions()
	result := string contains(extension)
	string free()
	result
}
printExtensions: func {
	array := getExtensionList()
	Debug print("OpenGL extensions:")
	for (i in 0 .. array count)
		Debug print(array[i])
	array free()
}
printVersionInfo: func {
	vendor: CString = glGetString(GL_VENDOR) as CString
	renderer: CString = glGetString(GL_RENDERER) as CString
	version: CString = glGetString(GL_VERSION) as CString

	Debug print~free("OpenGL vendor: %s" format(vendor))
	Debug print~free("OpenGL renderer: %s" format(renderer))
	Debug print~free("OpenGL version: %s" format(version))
}
}
}
