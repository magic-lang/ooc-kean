/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw-gpu
import OpenGLContext
import backend/GLVertexArrayObject

version(!gpuOff) {
OpenGLMesh: class extends GpuMesh {
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
}
