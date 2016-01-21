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
 * along with This software. If not, see <http://www.gnu.org/licenses/>.
 */

use geometry

import include/gles3
import ../GLQuad
import Gles3VertexArrayObject, Gles3Debug

version(!gpuOff) {
Gles3Quad: class extends GLQuad {
	init: func {
		version(debugGL) { validateStart("Quad init") }
		vertices := FloatPoint2D[4] new()
		vertices[0] = FloatPoint2D new(-1.0f, -1.0f)
		vertices[1] = FloatPoint2D new(-1.0f, 1.0f)
		vertices[2] = FloatPoint2D new(1.0f, -1.0f)
		vertices[3] = FloatPoint2D new(1.0f, 1.0f)
		textureCoordinates := FloatPoint2D[4] new()
		textureCoordinates[0] = FloatPoint2D new(0.0f, 1.0f)
		textureCoordinates[1] = FloatPoint2D new(0.0f, 0.0f)
		textureCoordinates[2] = FloatPoint2D new(1.0f, 1.0f)
		textureCoordinates[3] = FloatPoint2D new(1.0f, 0.0f)
		this vao = Gles3VertexArrayObject new(vertices, textureCoordinates)
		vertices free()
		textureCoordinates free()
		version(debugGL) { validateEnd("Quad init") }
	}
	free: override func {
		this vao free()
		super()
	}
	draw: override func {
		version(debugGL) { validateStart("Quad draw") }
		this vao bind()
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4)
		this vao unbind()
		version(debugGL) { validateEnd("Quad draw") }
	}
}
}
