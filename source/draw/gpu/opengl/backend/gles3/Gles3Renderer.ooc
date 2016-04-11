/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Gles3Quad
import external/gles3
import ../GLRenderer
import Gles3Debug

version(!gpuOff) {
Gles3Renderer: class extends GLRenderer {
	init: func { this _quad = Gles3Quad new() }
	free: override func {
		this _quad free()
		super()
	}
	drawQuad: override func { this _quad draw() }
	drawLines: override func (positions: Float*, count, dimensions: Int, lineWidth: Float) {
		version(debugGL) { validateStart("Renderer drawLines") }
		glLineWidth(lineWidth)
		glBindVertexArray(0)
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, dimensions, GL_FLOAT, 0, 0, positions)
		glDrawArrays(GL_LINE_STRIP, 0, count)
		glDisableVertexAttribArray(0)
		version(debugGL) { validateEnd("Renderer drawLines") }
	}
	drawPoints: override func (positions: Float*, count, dimensions: Int) {
		version(debugGL) { validateStart("Renderer drawPoints") }
		glBindVertexArray(0)
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, dimensions, GL_FLOAT, 0, 0, positions)
		glDrawArrays(GL_POINTS, 0, count)
		glDisableVertexAttribArray(0)
		version(debugGL) { validateEnd("Renderer drawPoints") }
	}
}
}
