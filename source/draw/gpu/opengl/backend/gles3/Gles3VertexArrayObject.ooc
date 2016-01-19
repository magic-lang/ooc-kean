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
use ooc-geometry
import include/gles3
import ../GLVertexArrayObject
import Gles3Debug

version(!gpuOff) {
Gles3VertexArrayObject: class extends GLVertexArrayObject {
	_backend: UInt
	_vertexCount: Int

	init: func ~twoDimensions (vertices, textureCoordinates: FloatPoint2D[]) {
		vertexCount := vertices length
		this _vertexCount = vertexCount
		floatsPerVertex := 4
		packedArray: Float[floatsPerVertex * vertexCount]
		for (i in 0 .. vertexCount) {
			//Positions
			packedArray[floatsPerVertex * i + 0] = vertices[i] x
			packedArray[floatsPerVertex * i + 1] = vertices[i] y
			//Texture coordinates
			packedArray[floatsPerVertex * i + 2] = textureCoordinates[i] x
			packedArray[floatsPerVertex * i + 3] = textureCoordinates[i] y
		}
		this _generate(packedArray[0]&, 2, vertexCount)
	}
	init: func ~threeDimensions (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
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
		version(debugGL) { validateStart("VertexArrayObject free") }
		glDeleteVertexArrays(1, this _backend&)
		version(debugGL) { validateEnd("VertexArrayObject free") }
		super()
	}
	_generate: func (packedArray: Float*, dimensions, vertexCount: Int) {
		version(debugGL) { validateStart("VertexArrayObject _generate") }
		glGenVertexArrays(1, this _backend&)
		glBindVertexArray(this _backend)

		vertexBuffer: UInt
		glGenBuffers(1, vertexBuffer&)
		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
		glBufferData(GL_ARRAY_BUFFER, (2 + dimensions) * Float size * vertexCount, packedArray, GL_STATIC_DRAW)

		positionOffset : ULong = 0
		textureCoordinateOffset : ULong = Float size * dimensions
		glVertexAttribPointer(positionLayout, dimensions, GL_FLOAT, GL_FALSE, Float size * (2 + dimensions), positionOffset as Pointer)
		glEnableVertexAttribArray(positionLayout)
		glVertexAttribPointer(textureCoordinateLayout, 2, GL_FLOAT, GL_FALSE, Float size * (2 + dimensions), textureCoordinateOffset as Pointer)
		glEnableVertexAttribArray(textureCoordinateLayout)

		glBindBuffer(GL_ARRAY_BUFFER, 0)
		glBindVertexArray(0)
		glDeleteBuffers(1, vertexBuffer&)
		version(debugGL) { validateEnd("VertexArrayObject _generate") }
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
	positionLayout: const static UInt = 0
	textureCoordinateLayout: const static UInt = 1
}
}
