/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import ../../DisplayContext
import ../egl/EglDisplayContext
import ../[GLContext, GLFence, GLTexture, GLVertexArrayObject, GLIndexBufferObject]
import external/gles3
import Gles3Debug, Gles3Fence, Gles3FramebufferObject, Gles3Quad, Gles3Renderer, Gles3ShaderProgram, Gles3Texture, Gles3VolumeTexture, Gles3VertexArrayObject, Gles3IndexBufferObject

version(!gpuOff) {
Gles3Context: class extends GLContext {
	_displayContext: DisplayContext
	getDisplayContextSafely: func -> DisplayContext { this == null ? null : this _displayContext }
	init: func (=_displayContext) { super() }
	free: override func {
		this _displayContext free()
		super()
	}
	getDisplay: override func -> Pointer { this _displayContext getDisplay() }
	swapBuffers: override func { this _displayContext swapBuffers() }
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
		result := This new(EglDisplayContext new(display, nativeBackend, sharedContext getDisplayContextSafely() as EglDisplayContext))
	}
	create: static func ~pbufferShared (sharedContext: This = null) -> This {
		result := This new(EglDisplayContext new(sharedContext getDisplayContextSafely() as EglDisplayContext))
	}
}
}
