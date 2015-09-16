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
import include/gles3

Vao: class {
	backend: UInt
	positionLayout: const static UInt = 0
	textureCoordinateLayout: const static UInt = 1
	init: func (positions: Float*, textureCoordinates: Float*, vertexCount: UInt, dimensions: UInt) -> Bool {
		version(debugGL) { Debug print("Allocating OpenGL VAO") }
		//Currently using 2 attributes: vertex position and texture coordinate
		attributeCount := 2
		packedArray: Float[attributeCount * vertexCount * dimensions]
		for (i in 0 .. vertexCount) {
			for (j in 0 .. dimensions) {
				packedArray[attributeCount * dimensions * i + j] = positions[dimensions * i + j]
				packedArray[attributeCount * dimensions * i + j + dimensions] = textureCoordinates[dimensions * i + j]
			}
		}

		glGenVertexArrays(1, backend&)
		glBindVertexArray(backend)
		vertexBuffer: UInt
		glGenBuffers(1, vertexBuffer&)

		glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer)
		glBufferData(GL_ARRAY_BUFFER, Float size * attributeCount * vertexCount * dimensions, packedArray[0]&, GL_STATIC_DRAW)

		positionOffset : ULong = 0
		textureCoordinateOffset : ULong = Float size * dimensions
		glVertexAttribPointer(positionLayout, dimensions, GL_FLOAT, GL_FALSE, Float size * dimensions * attributeCount, positionOffset as Pointer)
		glEnableVertexAttribArray(positionLayout)
		glVertexAttribPointer(textureCoordinateLayout, dimensions, GL_FLOAT, GL_FALSE, Float size * dimensions * attributeCount, textureCoordinateOffset as Pointer)
		glEnableVertexAttribArray(textureCoordinateLayout)

		glBindBuffer(GL_ARRAY_BUFFER, 0)
		glBindVertexArray(0)
		glDeleteBuffers(1, vertexBuffer&)
	}
	free: func {
		glDeleteVertexArrays(1, backend&)
		super()
	}
	bind: func { glBindVertexArray(backend) }
	unbind: func { glBindVertexArray(0) }
}
