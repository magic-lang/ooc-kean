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

version(!gpuOff) {
Gles3VertexBufferObject: class {
	_backend: UInt
	_vertexCount: Int
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
		vertexCount := vertices length
		this _vertexCount = vertexCount
		floatsPerVertex := 5
		packedArray: Float[vertexCount * floatsPerVertex]
		for (i in 0 .. vertexCount) {
			//Positions
			packedArray[floatsPerVertex * i + 0] = vertices[i] x
			packedArray[floatsPerVertex * i + 1] = vertices[i] y
			packedArray[floatsPerVertex * i + 2] = vertices[i] z
			//Texture coordinates
			packedArray[floatsPerVertex * i + 3] = textureCoordinates[i] x
			packedArray[floatsPerVertex * i + 4] = textureCoordinates[i] y
		}
		this _generate(packedArray[0]&, 3, vertexCount)
	}
	free: override func {
		version(debugGL) { validateStart("Gles3VertexBufferObject free") }
		version(debugGL) { validateEnd("Gles3VertexBufferObject free") }
		super()
	}
	_generate: func (packedArray: Float*, dimensions, vertexCount: Int) {
		version(debugGL) { validateStart("Gles3VertexBufferObject _generate") }
		glGenBuffers(1, this _backend&)
		glBindBuffer(GL_ARRAY_BUFFER, this _backend)
		glBufferData(GL_ARRAY_BUFFER, (2 + dimensions) * Float size * vertexCount, packedArray, GL_STATIC_DRAW)

		positionOffset: ULong = 0
		textureCoordinateOffset: ULong = Float size * dimensions
		glVertexAttribPointer(positionLayout, dimensions, GL_FLOAT, GL_FALSE, Float size * (2 + dimensions), positionOffset as Pointer)
		glEnableVertexAttribArray(positionLayout)
		glVertexAttribPointer(textureCoordinateLayout, 2, GL_FLOAT, GL_FALSE, Float size * (2 + dimensions), textureCoordinateOffset as Pointer)
		glEnableVertexAttribArray(textureCoordinateLayout)

		glBindBuffer(GL_ARRAY_BUFFER, 0)
		version(debugGL) { validateEnd("Gles3VertexBufferObject _generate") }
	}
	bind: override func {
		version(debugGL) { validateStart("Gles3VertexBufferObject bind") }
		glBindBuffer(GL_ARRAY_BUFFER, this _backend)
		version(debugGL) { validateEnd("Gles3VertexBufferObject bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("Gles3VertexBufferObject unbind") }
		glBindBuffer(GL_ARRAY_BUFFER, 0)
		version(debugGL) { validateEnd("Gles3VertexBufferObject unbind") }
	}
	draw: override func {
		this bind()
		version(debugGL) { validateStart("Gles3VertexBufferObject draw") }
		glDrawArrays(GL_TRIANGLE_STRIP, 0, this _vertexCount)
		version(debugGL) { validateEnd("Gles3VertexBufferObject draw") }
		this unbind()
	}
	positionLayout: static UInt = 0
	textureCoordinateLayout: static UInt = 1
}
}
