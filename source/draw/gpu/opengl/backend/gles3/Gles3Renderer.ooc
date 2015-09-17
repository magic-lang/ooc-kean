/*
 * Copyright (C) 2015 - Simon Mika <simon@mika.se>
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
import Gles3Quad
import include/gles3
import ../GLRenderer

Gles3Renderer: class extends GLRenderer {
	init: func { this _quad = Gles3Quad new() }
	free: override func { this _quad free() }
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
