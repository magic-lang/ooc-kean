/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
import external/gles3
import ../GLVertexArrayObject
import Gles3VertexBufferObject
import Gles3Debug

version(!gpuOff) {
Gles3VertexArrayObject: class extends GLVertexArrayObject {
	_backend: UInt
	_vertexCount: Int
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
		vertexCount := vertices length
		this _vertexCount = vertexCount
		glGenVertexArrays(1, this _backend&)
		glBindVertexArray(this _backend)
		vbo := Gles3VertexBufferObject new(vertices, textureCoordinates)
		vbo bind()
		vbo unbind()
		glBindVertexArray(0)
		vbo free()
	}
	free: override func {
		version(debugGL) { validateStart("VertexArrayObject free") }
		glDeleteVertexArrays(1, this _backend&)
		version(debugGL) { validateEnd("VertexArrayObject free") }
		super()
	}
	bind: override func {
		version(debugGL) { validateStart("VertexArrayObject bind") }
		glBindVertexArray(this _backend)
		version(debugGL) { validateEnd("VertexArrayObject bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("VertexArrayObject unbind") }
		glBindVertexArray(0)
		version(debugGL) { validateEnd("VertexArrayObject unbind") }
	}
	draw: override func {
		this bind()
		version(debugGL) { validateStart("VertexArrayObject draw") }
		glDrawArrays(GL_TRIANGLE_STRIP, 0, this _vertexCount)
		version(debugGL) { validateEnd("VertexArrayObject draw") }
		this unbind()
	}
	positionLayout: static UInt = 0
	textureCoordinateLayout: static UInt = 1
}
}
