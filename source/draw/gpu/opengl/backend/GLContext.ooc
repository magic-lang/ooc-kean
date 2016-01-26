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

use base
use geometry
import gles3/Gles3Context
import GLQuad, GLShaderProgram, GLTexture, GLFramebufferObject, GLFence, GLVolumeTexture, GLRenderer, GLVertexArrayObject

version(!gpuOff) {
GLContext: abstract class {
	_eglDisplay: Pointer

	makeCurrent: abstract func -> Bool
	swapBuffers: abstract func
	setViewport: abstract func (viewport: IntBox2D)
	enableBlend: abstract func (on: Bool)
	blend: abstract func ~constant (factor: Float)
	blend: abstract func ~alphaMonochrome
	createFence: abstract func -> GLFence
	createFramebufferObject: abstract func (texture: GLTexture, size: IntVector2D) -> GLFramebufferObject
	createQuad: abstract func -> GLQuad
	createShaderProgram: abstract func (vertexSource, fragmentSource: String) -> GLShaderProgram
	createTexture: abstract func (type: TextureType, size: IntVector2D, stride: UInt, pixels := null, allocate : Bool = true) -> GLTexture
	createVolumeTexture: abstract func (size: IntVector3D, pixels: Byte*) -> GLVolumeTexture
	createRenderer: abstract func -> GLRenderer
	createVertexArrayObject: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) -> GLVertexArrayObject
	createContext: static func ~shared (display: Pointer, nativeBackend: Long, sharedContext: This = null) -> This {
		// This function will check whether a context creation succeeded and if not try to create a context for another OpenGL version
		Gles3Context create(display, nativeBackend, sharedContext as Gles3Context)
	}
	createContext: static func ~pbufferShared (sharedContext: This = null) -> This {
		// This function will check whether a context creation succeeded and if not try to create a context for another OpenGL version
		Gles3Context create(sharedContext as Gles3Context)
	}
}
}
