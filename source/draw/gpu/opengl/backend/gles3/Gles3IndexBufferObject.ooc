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
import Gles3Debug
import Gles3VertexBufferObject
import ../GLIndexBufferObject

version(!gpuOff) {
Gles3IndexBufferObject: class extends GLIndexBufferObject {
	_backend: UInt
	_vbo: Gles3VertexBufferObject
	_indexCount: Int
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], triangleIndices: IntPoint3D[]) {
		super()
		this _indexCount = 3 * triangleIndices length
		glGenBuffers(1, this _backend&)
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this _backend)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangleIndices length * IntPoint3D size, triangleIndices data, GL_STATIC_DRAW)
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
		this _vbo = Gles3VertexBufferObject new(vertices, textureCoordinates)
	}
	free: override func {
		version(debugGL) { validateStart("Gles3IndexBufferObject free") }
		this _vbo free()
		glDeleteBuffers(1, this _backend&)
		version(debugGL) { validateEnd("Gles3IndexBufferObject free") }
		super()
	}
	bind: override func {
		version(debugGL) { validateStart("Gles3IndexBufferObject bind") }
		this _vbo bind()
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this _backend)
		version(debugGL) { validateEnd("Gles3IndexBufferObject bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("Gles3IndexBufferObject unbind") }
		this _vbo unbind()
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
		version(debugGL) { validateEnd("Gles3IndexBufferObject unbind") }
	}
	draw: override func {
		version(debugGL) { validateStart("Gles3IndexBufferObject draw") }
		this bind()
		glDrawElements(GL_TRIANGLES, this _indexCount, GL_UNSIGNED_INT, 0 as Pointer)
		this unbind()
		version(debugGL) { validateEnd("Gles3IndexBufferObject draw") }
	}
	positionLayout: static UInt = 0
	textureCoordinateLayout: static UInt = 1
}
}
