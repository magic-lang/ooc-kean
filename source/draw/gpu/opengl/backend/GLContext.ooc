/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import gles3/Gles3Context
import GLQuad, GLShaderProgram, GLTexture, GLFramebufferObject, GLFence, GLVolumeTexture, GLRenderer, GLVertexArrayObject, GLExtensions, GLIndexBufferObject

GLContext: abstract class {
	init: func { GLExtensions initialize() }
	swapBuffers: abstract func
	setViewport: abstract func (viewport: IntBox2D)
	disableBlend: abstract func
	blendAdd: abstract func
	blendWhite: abstract func
	blendAlpha: abstract func
	createFence: abstract func -> GLFence
	createFramebufferObject: abstract func (texture: GLTexture, size: IntVector2D) -> GLFramebufferObject
	createQuad: abstract func -> GLQuad
	createShaderProgram: abstract func (vertexSource, fragmentSource: String) -> GLShaderProgram
	createTexture: abstract func (type: TextureType, size: IntVector2D, stride: UInt, pixels := null, allocate : Bool = true) -> GLTexture
	createVolumeTexture: abstract func (size: IntVector3D, pixels: Byte*) -> GLVolumeTexture
	createRenderer: abstract func -> GLRenderer
	createVertexArrayObject: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GLVertexArrayObject
	createIndexBufferObject: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], indices: IntPoint3D[]) -> GLIndexBufferObject
	getDisplay: abstract func -> Pointer
	createContext: static func ~shared (display: Pointer, nativeBackend: Long, sharedContext: This = null) -> This {
		result: This = null
		version (!gpuOff) {
			// This function will check whether a context creation succeeded and if not try to create a context for another OpenGL version
			result = Gles3Context create(display, nativeBackend, sharedContext as Gles3Context)
		}
		result
	}
	createContext: static func ~pbufferShared (sharedContext: This = null) -> This {
		result: This = null
		version (!gpuOff) {
			// This function will check whether a context creation succeeded and if not try to create a context for another OpenGL version
			result = Gles3Context create(sharedContext as Gles3Context)
		}
		result
	}
}
