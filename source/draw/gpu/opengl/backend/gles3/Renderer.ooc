
import Quad
import include/gles3
Renderer: class {
	_quad: Quad
	init: func { this _quad = Quad new() }
	free: override func {
		this _quad free()
		super()
	}
	drawQuad: func { this _quad draw() }
	drawLines: func (positions: Float*, count: Int, dimensions: Int, lineWidth: Float) {
		glLineWidth(lineWidth)
		glBindVertexArray(0)
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, dimensions, GL_FLOAT, 0, 0, positions)
		glDrawArrays(GL_LINE_STRIP, 0, count)
		glDisableVertexAttribArray(0)
	}
	drawPoints: func (positions: Float*, count: Int, dimensions: Int) {
		glBindVertexArray(0)
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, dimensions, GL_FLOAT, 0, 0, positions)
		glDrawArrays(GL_POINTS, 0, count)
		glDisableVertexAttribArray(0)
	}
}
