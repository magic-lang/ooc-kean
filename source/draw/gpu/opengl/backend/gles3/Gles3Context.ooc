/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */
use ooc-base
use ooc-math
use ooc-ui
import ../egl/egl
import include/gles3
import DebugGL

Gles3Context: class extends GLContext {
	init: func
	free: override func {
		eglMakeCurrent(this _eglDisplay, null, null, null)
		eglDestroyContext(this _eglDisplay, this _eglContext)
		eglDestroySurface(this _eglDisplay, this _eglSurface)
		eglTerminate(this _eglDisplay)
	}
	makeCurrent: func -> Bool {
		result := eglMakeCurrent(this _eglDisplay, this _eglSurface, this _eglSurface, this _eglContext) != 0
		version(debugGL) {
			if (result)
				printVersionInfo()
		}
		result
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
		this _eglContext = eglCreateContext(this _eglDisplay, config, shared, contextAttribs)
		if (this _eglContext == null) {
			"Failed to create OpenGL ES 3 context, trying with OpenGL ES 2 instead" println()
			contextAttribs = [
				EGL_CONTEXT_CLIENT_VERSION, 2,
				EGL_NONE] as Int*
			this _eglContext = eglCreateContext(this _eglDisplay, config, shared, contextAttribs)
			if (this _eglContext == null)
				raise("Failed to create OpenGL ES 3 or OpenGL ES 2 context")
			else
				"WARNING: Using OpenGL ES 2" println()
		}
	}
	_generate: func (window: NativeWindow, sharedContext: This) -> Bool {
		this _eglDisplay = eglGetDisplay(window display)
		if (this _eglDisplay == null)
			return false
		eglInitialize(this _eglDisplay, null, null)
		eglBindAPI(EGL_OPENGL_ES_API)
		configAttribs := [
			EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
			EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
			EGL_BUFFER_SIZE, 16,
			EGL_NONE] as Int*
		chosenConfig: Pointer = this _chooseConfig(configAttribs)

		this _eglSurface = eglCreateWindowSurface(this _eglDisplay, chosenConfig, window backend, null)
		if (this _eglSurface == null)
			return false

		shared: Pointer = null
		if (sharedContext)
			shared = sharedContext _eglContext
		this _generateContext(shared, chosenConfig)
		this makeCurrent()
	}
	_generate: func ~pbuffer (sharedContext: This) -> Bool {
		this _eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY)
		if (this _eglDisplay == null)
			raise("Failed to get default display")
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
			EGL_BIND_TO_TEXTURE_RGBA, EGL_TRUE,
			EGL_NONE] as Int*
		chosenConfig: Pointer = this _chooseConfig(configAttribs)

		pbufferAttribs := [
			EGL_WIDTH, 1,
			EGL_HEIGHT, 1,
			EGL_TEXTURE_TARGET, EGL_NO_TEXTURE,
			EGL_TEXTURE_FORMAT, EGL_NO_TEXTURE,
			EGL_NONE] as Int*
		this _eglSurface = eglCreatePbufferSurface(this _eglDisplay, chosenConfig, pbufferAttribs)
		if (this _eglSurface == null)
			return false

		shared: Pointer = null
		if (sharedContext != null)
			shared = sharedContext _eglContext
		this _generateContext(shared, chosenConfig)
		this makeCurrent()
	}
	setViewport: func (viewport: IntBox2D) {
		version(debugGL) { validateStart() }
		glViewport(viewport left, viewport top, viewport width, viewport height)
		version(debugGL) { validateEnd("context setViewport") }
	}
	enableBlend: func (on: Bool) {
		version(debugGL) { validateStart() }
		if (on)
			glEnable(GL_BLEND)
		else
			glDisable(GL_BLEND)
		version(debugGL) { validateEnd("context enableBlend") }
	}
	blend: func ~constant (factor: Float) {
		version(debugGL) { validateStart() }
		glEnable(GL_BLEND)
		glBlendColor(factor, factor, factor, factor)
		glBlendFunc(GL_CONSTANT_COLOR, GL_ONE_MINUS_CONSTANT_COLOR)
		version(debugGL) { validateEnd("context blend~constant") }
	}
	blend: func ~alphaMonochrome {
		version(debugGL) { validateStart() }
		glEnable(GL_BLEND)
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR)
		version(debugGL) { validateEnd("context blend~alphaMonochrome") }
	}
	create: static func ~shared (window: NativeWindow, sharedContext: This = null) -> This {
		version(debugGL) { Debug print("Creating OpenGL context") }
		result := This new()
		result _generate(window, sharedContext) ? result : null
	}
	create: static func ~pbufferShared (sharedContext: This = null) -> This {
		version(debugGL) { Debug print("Creating OpenGL context") }
		result := This new()
		result _generate(sharedContext) ? result : null
	}

	createQuad: func -> Gles3Quad {
		version(debugGL) { validateStart() }
		result := Gles3Quad new()
		result = (result vao != null) ? result : null
		version(debugGL) { validateEnd("quad create") }
		result
	}
	createShaderProgram: func (vertexSource, fragmentSource: String) -> Gles3ShaderProgram {
		version(debugGL) { validateStart() }
		result := Gles3ShaderProgram new()
		result = result _compileShaders(vertexSource, fragmentSource) ? result : null
		version(debugGL) { validateEnd("ShaderProgram create") }
		result
	}
	createTexture: func (type: TextureType, size: IntSize2D, stride: UInt, pixels := null, allocate : Bool = true) -> Gles3Texture {
		version(debugGL) { validateStart() }
		result := Gles3Texture new(type, size)
		success := result _generate(pixels, stride, allocate)
		result = success ? result : null
		version(debugGL) { validateEnd("Texture create") }
		result
	}
	createFramebufferObject: func (texture: GLTexture, size: IntSize2D) -> Gles3FramebufferObject {
		version(debugGL) { validateStart() }
		result := Gles3FramebufferObject new(size)
		result = result _generate(texture as Gles3Texture) ? result : null
		version(debugGL) { validateEnd("fbo create") }
		result
	}
	createFence: func -> Gles3Fence {
		version(debugGL) { validateStart() }
		result := Gles3Fence new()
		version(debugGL) { validateEnd("Fence create") }
		result
	}
	createVolumeTexture: func (width, height, depth: UInt, pixels: UInt8*) -> Gles3VolumeTexture {
		version(debugGL) { validateStart() }
		result := Gles3VolumeTexture new(width, height, depth, pixels)
		version(debugGL) { validateEnd("VolumeTexture create") }
		result
	}
	createRenderer: func -> Gles3Renderer {
		version(debugGL) { validateStart() }
		result := Gles3Renderer new()
		version(debugGL) { validateEnd("Renderer create") }
		result
	}
}
