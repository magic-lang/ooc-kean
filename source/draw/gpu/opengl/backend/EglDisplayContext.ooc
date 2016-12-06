/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

version(!gpuOff) {
use base
use geometry
import egl/egl

EglDisplayContext: class {
	_eglDisplay: Pointer
	_eglContext: Pointer
	_eglSurface: Pointer
	_contextCount := static 0
	_mutex := static Mutex new()
	init: func (display: Pointer, nativeBackend: Long, sharedContext: This) {
		this _initializeDisplay(display)
		This validate(eglBindAPI(EGL_OPENGL_ES_API), EGL_TRUE, "eglBindAPI")
		configAttribs := [
			EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
			EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
			EGL_BUFFER_SIZE, 16,
			EGL_NONE] as Int*
		chosenConfig: Pointer = this _chooseConfig(configAttribs)
		this _eglSurface = eglCreateWindowSurface(this _eglDisplay, chosenConfig, nativeBackend, null)
		This validate(this _eglSurface != EGL_NO_SURFACE, "eglCreateWindowSurface")
		this _generateContext(sharedContext ? sharedContext _eglContext : null , chosenConfig)
	}
	init: func ~pbuffer (sharedContext: This) {
		this _initializeDisplay(EGL_DEFAULT_DISPLAY)
		This validate(eglBindAPI(EGL_OPENGL_ES_API), EGL_TRUE, "eglBindAPI")
		configAttribs := [
			EGL_SURFACE_TYPE, EGL_PBUFFER_BIT,
			EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
			EGL_BLUE_SIZE, 8,
			EGL_GREEN_SIZE, 8,
			EGL_RED_SIZE, 8,
			EGL_ALPHA_SIZE, 8,
			EGL_SAMPLES, 0,
			EGL_DEPTH_SIZE, 0,
			EGL_BIND_TO_TEXTURE_RGBA, EGL_DONT_CARE,
			EGL_NONE] as Int*
		chosenConfig: Pointer = this _chooseConfig(configAttribs)
		pbufferAttribs := [
			EGL_WIDTH, 1,
			EGL_HEIGHT, 1,
			EGL_TEXTURE_TARGET, EGL_NO_TEXTURE,
			EGL_TEXTURE_FORMAT, EGL_NO_TEXTURE,
			EGL_NONE] as Int*
		this _eglSurface = eglCreatePbufferSurface(this _eglDisplay, chosenConfig, pbufferAttribs)
		This validate(this _eglSurface != EGL_NO_SURFACE, "eglCreatePbufferSurface")
		this _generateContext(sharedContext ? sharedContext _eglContext : null, chosenConfig)
	}
	free: override func {
		This validate(eglMakeCurrent(this _eglDisplay, null, null, null), EGL_TRUE, "eglMakeCurrent")
		This validate(eglDestroyContext(this _eglDisplay, this _eglContext), EGL_TRUE, "eglDestroyContext")
		This validate(eglDestroySurface(this _eglDisplay, this _eglSurface), EGL_TRUE, "eglDestroySurface")
		This _mutex with(||
			if (This _contextCount == 1)
				This validate(eglTerminate(this _eglDisplay), EGL_TRUE, "eglTerminate")
			This _contextCount -= 1
		)
		super()
	}
	getDisplay: func -> Pointer { this _eglDisplay }
	printExtensions: func {
		extensions := eglQueryString(this _eglDisplay, EGL_EXTENSIONS) as CString
		extensionsString := String new(extensions, extensions length())
		array := extensionsString split(' ')
		extensionsString free()
		Debug print("EGL Extensions: ")
		for (i in 0 .. array count)
			Debug print(array[i])
		array free()
	}
	swapBuffers: func { eglSwapBuffers(this _eglDisplay, this _eglSurface) }
	_chooseConfig: func (configAttribs: Int*) -> Pointer {
		numConfigs: Int
		eglChooseConfig(this _eglDisplay, configAttribs, null, 10, numConfigs&)
		matchingConfigs: Pointer[numConfigs]
		eglChooseConfig(this _eglDisplay, configAttribs, matchingConfigs[0]&, numConfigs, numConfigs&)
		chosenConfig: Pointer = null

		for (i in 0 .. numConfigs) {
			success: UInt
			red, green, blue, alpha: Int
			success = eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_RED_SIZE, red&)
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_GREEN_SIZE, green&)
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_BLUE_SIZE, blue&)
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_ALPHA_SIZE, alpha&)

			if (success && red == 8 && green == 8 && blue == 8 && alpha == 8) {
				chosenConfig = matchingConfigs[i]
				break
			}
		}
		chosenConfig
	}
	_generateContext: func (shared, config: Pointer) {
		contextAttribs := [
			EGL_CONTEXT_CLIENT_VERSION, 3,
			EGL_NONE] as Int*
		This _mutex with(|| This _contextCount += 1)
		this _eglContext = eglCreateContext(this _eglDisplay, config, shared, contextAttribs)
		if (this _eglContext == null) {
			Debug print("Failed to create OpenGL ES 3 context, trying with OpenGL ES 2 instead")
			contextAttribs = [
				EGL_CONTEXT_CLIENT_VERSION, 2,
				EGL_NONE] as Int*
			this _eglContext = eglCreateContext(this _eglDisplay, config, shared, contextAttribs)
			if (this _eglContext == null)
				Debug error("Failed to create OpenGL ES 3 or OpenGL ES 2 context")
			else
				Debug print("WARNING: Using OpenGL ES 2")
		}
		This validate(eglMakeCurrent(this _eglDisplay, this _eglSurface, this _eglSurface, this _eglContext), EGL_TRUE, "eglMakeCurrent")
	}
	_initializeDisplay: func (display: Pointer) {
		this _eglDisplay = eglGetDisplay(display)
		This validate(this _eglDisplay != EGL_NO_DISPLAY, "eglGetDisplay")
		This validate(eglInitialize(this _eglDisplay, null, null), EGL_TRUE, "eglInitialize")
	}
	validate: static func (value, expectedValue: UInt, function: String) {
		if (value != expectedValue)
			Debug error(function << " failed! Expected status %u but got %u. eglError=%d" format(expectedValue, value, eglGetError()))
	}
	validate: static func ~expression (success: Bool, function: String) {
		if (!success)
			Debug error(function << " failed with eglError=%d" format(eglGetError()))
	}
}
GlobalCleanup register(|| EglDisplayContext _mutex free(), 10)
}
