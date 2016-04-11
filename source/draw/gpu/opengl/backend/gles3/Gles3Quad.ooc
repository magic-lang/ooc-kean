/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry

import external/gles3
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
		(vertices, textureCoordinates) free()
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
