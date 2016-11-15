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
import ../egl/egl
import ../[GLContext, GLTexture, GLVertexArrayObject, GLIndexBufferObject]
import external/gles3
import Gles3Debug, Gles3Fence, Gles3FramebufferObject, Gles3Quad, Gles3Renderer, Gles3ShaderProgram, Gles3Texture, Gles3VolumeTexture, Gles3VertexArrayObject, Gles3IndexBufferObject

Gles3Context: class extends GLContext {
	_eglContext: Pointer
	_eglSurface: Pointer
	_contextCount := static 0
	_mutex := static Mutex new()
	init: func { super() }
	free: override func {
		status := eglMakeCurrent(this _eglDisplay, null, null, null)
		if (status != EGL_TRUE)
			Debug print("eglMakeCurrent failed with error code %d" format(status))
		status = eglDestroyContext(this _eglDisplay, this _eglContext)
		if (status != EGL_TRUE)
			Debug print("eglDestroyContext failed with error code %d" format(status))
		status = eglDestroySurface(this _eglDisplay, this _eglSurface)
		if (status != EGL_TRUE)
			Debug print("eglDestroySurface failed with error code %d" format(status))
		This _mutex with(||
			if (This _contextCount == 1) {
				status = eglTerminate(this _eglDisplay)
				if (status != EGL_TRUE)
					Debug print("eglTerminate failed with error code %d" format(status))
			}
			This _contextCount -= 1
		)
		super()
	}
	makeCurrent: override func -> Bool { eglMakeCurrent(this _eglDisplay, this _eglSurface, this _eglSurface, this _eglContext) != 0 }
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
	swapBuffers: override func { eglSwapBuffers(this _eglDisplay, this _eglSurface) }
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
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_BLUE_SIZE, blue&)
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_GREEN_SIZE, green&)
			success &= eglGetConfigAttrib(this _eglDisplay, matchingConfigs[i], EGL_ALPHA_SIZE, alpha&)

			if (success && red == 8 && blue == 8 && green == 8 && alpha == 8) {
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
	}
	_generate: func (display: Pointer, nativeBackend: Long, sharedContext: This) -> Bool {
		result := false
		this _eglDisplay = eglGetDisplay(display)
		if (this _eglDisplay) {
			eglInitialize(this _eglDisplay, null, null)
			eglBindAPI(EGL_OPENGL_ES_API)
			configAttribs := [
				EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
				EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
				EGL_BUFFER_SIZE, 16,
				EGL_NONE] as Int*
			chosenConfig: Pointer = this _chooseConfig(configAttribs)

			this _eglSurface = eglCreateWindowSurface(this _eglDisplay, chosenConfig, nativeBackend, null)
			if (this _eglSurface) {
				shared: Pointer = null
				if (sharedContext)
					shared = sharedContext _eglContext
				this _generateContext(shared, chosenConfig)
				result = this makeCurrent()
			}
		}
		result
	}
	_generate: func ~pbuffer (sharedContext: This) -> Bool {
		this _eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY)
		if (this _eglDisplay == null)
			Debug error("Failed to get default display")
		eglInitialize(this _eglDisplay, null, null)
		eglBindAPI(EGL_OPENGL_ES_API)

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

		result := false
		if (this _eglSurface) {
			shared: Pointer = null
			if (sharedContext != null)
				shared = sharedContext _eglContext
			this _generateContext(shared, chosenConfig)
			result = this makeCurrent()
		}
		result
	}
	setViewport: override func (viewport: IntBox2D) {
		version(debugGL) { validateStart("Context setViewport") }
		glViewport(viewport left, viewport top, viewport width, viewport height)
		version(debugGL) { validateEnd("Context setViewport") }
	}
	disableBlend: override func {
		version(debugGL) { validateStart("Context disableBlend") }
		glDisable(GL_BLEND)
		version(debugGL) { validateEnd("Context disableBlend") }
	}
	blendAdd: override func {
		version(debugGL) { validateStart("Context blendAdd") }
		glEnable(GL_BLEND)
		glBlendEquation(GL_FUNC_ADD)
		glBlendFunc(GL_ONE, GL_ONE)
		version(debugGL) { validateEnd("Context blendAdd") }
	}
	blendWhite: override func {
		version(debugGL) { validateStart("Context blendWhite") }
		glEnable(GL_BLEND)
		glBlendEquation(GL_FUNC_ADD)
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR)
		version(debugGL) { validateEnd("Context blendWhite") }
	}
	blendAlpha: override func {
		version(debugGL) { validateStart("Context blendAlpha") }
		glEnable(GL_BLEND)
		glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD)
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE)
		version(debugGL) { validateEnd("Context blendAlpha") }
	}
	createQuad: override func -> Gles3Quad {
		result := Gles3Quad new()
		(result vao != null) ? result : null
	}
	createShaderProgram: override func (vertexSource, fragmentSource: String) -> Gles3ShaderProgram {
		result := Gles3ShaderProgram new()
		result _compileShaders(vertexSource, fragmentSource) ? result : null
	}
	createTexture: override func (type: TextureType, size: IntVector2D, stride: UInt, pixels := null, allocate := true) -> Gles3Texture {
		result := Gles3Texture new(type, size)
		success := result _generate(pixels, stride, allocate)
		success ? result : null
	}
	createFramebufferObject: override func (texture: GLTexture, size: IntVector2D) -> Gles3FramebufferObject {
		version(debugGL) { validateStart("Context createFramebufferObject") }
		result := Gles3FramebufferObject new(size)
		result = result _generate(texture as Gles3Texture) ? result : null
		version(debugGL) { validateEnd("Context createFramebufferObject") }
		result
	}
	createFence: override func -> Gles3Fence { Gles3Fence new() }
	createVolumeTexture: override func (size: IntVector3D, pixels: Byte*) -> Gles3VolumeTexture {
		Gles3VolumeTexture new(size, pixels)
	}
	createRenderer: override func -> Gles3Renderer { Gles3Renderer new() }
	createVertexArrayObject: override func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GLVertexArrayObject {
		Gles3VertexArrayObject new(vertices, textureCoordinates)
	}
	createIndexBufferObject: override func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], indices: IntPoint3D[]) -> GLIndexBufferObject {
		Gles3IndexBufferObject new(vertices, textureCoordinates, indices)
	}
	create: static func ~shared (display: Pointer, nativeBackend: Long, sharedContext: This = null) -> This {
		version(debugGL) { Debug print("Creating OpenGL Context") }
		result := This new()
		result _generate(display, nativeBackend, sharedContext) ? result : null
	}
	create: static func ~pbufferShared (sharedContext: This = null) -> This {
		version(debugGL) { Debug print("Creating OpenGL Context") }
		result := This new()
		result _generate(sharedContext) ? result : null
	}
}

GlobalCleanup register(|| Gles3Context _mutex free(), 10)
}
