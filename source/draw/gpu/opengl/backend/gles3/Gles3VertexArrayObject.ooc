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

use ooc-base
use ooc-math
import include/gles3
import ../GLVertexArrayObject
import Gles3Debug

Gles3VertexArrayObject: class extends GLVertexArrayObject {
	_backend: UInt
	positionLayout: const static UInt = 0
	textureCoordinateLayout: const static UInt = 1
	_vertexCount: Int

	init: func (positions, textureCoordinates: Float*, vertexCount, dimensions: UInt) {
		version(debugGL) { validateStart() }
		attributeCount := 2
		packedArray: Float[attributeCount * vertexCount * dimensions]
		for (i in 0 .. vertexCount) {
			for (j in 0 .. dimensions) {
				packedArray[attributeCount * dimensions * i + j] = positions[dimensions * i + j]
				packedArray[attributeCount * dimensions * i + j + dimensions] = textureCoordinates[dimensions * i + j]
			}
		}
		this _generate(packedArray[0]&, 2, vertexCount)
	}
	init: func ~twoDimensions (positions: FloatPoint2D[], textureCoordinates: FloatPoint2D[]) {
		vertexCount := positions length
		this _vertexCount = vertexCount
		floatsPerVertex := 4
		packedArray: Float[floatsPerVertex * vertexCount]
		for (i in 0 .. vertexCount) {
			//Positions
			packedArray[floatsPerVertex * i + 0] = positions[i] x
			packedArray[floatsPerVertex * i + 1] = positions[i] y
			//Texture coordinates
			packedArray[floatsPerVertex * i + 2] = textureCoordinates[i] x
			packedArray[floatsPerVertex * i + 3] = textureCoordinates[i] y
		}
		this _generate(packedArray[0]&, 2, vertexCount)
	}
	init: func ~threeDimensions (positions: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
		vertexCount := positions length
		this _vertexCount = vertexCount
		floatsPerVertex := 5
		packedArray: Float[vertexCount * floatsPerVertex]
		for (i in 0 .. vertexCount) {
			//Positions
			packedArray[floatsPerVertex * i + 0] = positions[i] x
			packedArray[floatsPerVertex * i + 1] = positions[i] y
			packedArray[floatsPerVertex * i + 2] = positions[i] z
			//Texture coordinates
			packedArray[floatsPerVertex * i + 3] = textureCoordinates[i] x
			packedArray[floatsPerVertex * i + 4] = textureCoordinates[i] y
		}
		this _generate(packedArray[0]&, 3, vertexCount)
	}
	_generate: func (packedArray: Float*, dimensions: Int, vertexCount: Int) {
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
		version(debugGL) { validateEnd("VertexArrayObject init") }
	}
	free: override func {
		version(debugGL) { validateStart() }
		glDeleteVertexArrays(1, this _backend&)
		version(debugGL) { validateEnd("VertexArrayObject free") }
		super()
	}
	bind: func {
		version(debugGL) { validateStart() }
		glBindVertexArray(this _backend)
		version(debugGL) { validateEnd("VertexArrayObject bind") }
	}
	unbind: func {
		version(debugGL) { validateStart() }
		glBindVertexArray(0)
		version(debugGL) { validateEnd("VertexArrayObject unbind") }
	}
	draw: func {
		this bind()
		glDrawArrays(GL_TRIANGLE_STRIP, 0, this _vertexCount)
		this unbind()
	}
}
