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
import backend/GLIndexBufferObject

version(!gpuOff) {
OpenGLMesh: abstract class extends Mesh {
	new: static func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], context: OpenGLContext) -> This {
		_VAOMesh new(vertices, textureCoordinates, context)
	}
	new: static func ~indices (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], indices: IntPoint3D[], context: OpenGLContext) -> This {
		_IBOMesh new(vertices, textureCoordinates, indices, context)
	}
}

_VAOMesh: class extends OpenGLMesh {
	_backend: GLVertexArrayObject
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], context: OpenGLContext) {
		this _backend = context backend createVertexArrayObject(vertices, textureCoordinates)
	}
	free: override func {
		this _backend free()
		super()
	}
	draw: override func { this _backend draw() }
}

_IBOMesh: class extends OpenGLMesh {
	_backend: GLIndexBufferObject
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], indices: IntPoint3D[], context: OpenGLContext) {
		this _backend = context backend createIndexBufferObject(vertices, textureCoordinates, indices)
	}
	free: override func {
		this _backend free()
		super()
	}
	draw: override func { this _backend draw() }
}
}
