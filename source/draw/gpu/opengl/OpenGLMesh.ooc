/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use draw-gpu
import OpenGLContext
import backend/GLVertexArrayObject
import backend/gles3/Gles3IndexBufferObject

version(!gpuOff) {
OpenGLMesh: class extends Mesh {
	_backend: GLVertexArrayObject = null
	_ibo: Gles3IndexBufferObject = null
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], context: OpenGLContext) {
		this _backend = context backend createVertexArrayObject(vertices, textureCoordinates)
	}
	init: func ~indices (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], indices: IntPoint3D[]) {
		this _ibo = Gles3IndexBufferObject new(vertices, textureCoordinates, indices)
	}
	free: override func {
		if (this _backend != null)
			this _backend free()
		else
			this _ibo free()
		super()
	}
	draw: override func {
		if (this _backend != null)
			this _backend draw()
		else
			this _ibo draw()
	}
}
}
