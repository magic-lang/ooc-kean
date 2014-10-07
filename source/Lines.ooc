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

import include/gles
import ShaderProgram
import structs/LinkedList
use ooc-math

Lines: class {
	defaultVertexSource: static String = "#version 300 es\n
	precision highp float;\n
	uniform int screenWidth;\n
	uniform int screenHeight;\n
	layout(location = 0) in vec2 vertexPosition;\n
	void main() {\n
		mat4 projectionMatrix = transpose(mat4(2.0f / float(screenWidth), 0, 0, 0, 0, -2.0f / float(screenHeight), 0, 0, 0, 0, -1, 0, 0, 0, 0, 1));\n
		gl_Position = vec4(vertexPosition, 0, 1);\n
	}\n";
	fragmentSource: static String = "#version 300 es\n
	precision highp float;\n
	out vec4 outColor;\n
	void main() {\n
		outColor = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n
	}\n";

	defaultVertexSourceAndroid: static String = "#version 300 es\n
	uniform int screenWidth;\n
	uniform int screenHeight;\n
	layout(location = 0) in vec2 vertexPosition;\n
	void main() {\n
		mat4 projectionMatrix = transpose(mat4(2.0f / float(screenWidth), 0, 0, 0, 0, 2.0f / float(screenHeight), 0, 0, 0, 0, -1, 0, 0, 0, 0, 1));\n
		gl_Position = vec4(vertexPosition, 0, 1);\n
	}\n";
	fragmentSourceAndroid: static String = "#version 300 es\n
	out float outColor;\n
	void main() {\n
		outColor = 1.0f;\n
	}\n";
	pointList: static LinkedList<FloatPoint2D>
	program: ShaderProgram
	positions: Float*
	pointCount: Int = 60

	init: func {
		version(debug) {
			program = ShaderProgram create(defaultVertexSource, fragmentSource)
		}
		else {
			program = ShaderProgram create(defaultVertexSourceAndroid, fragmentSourceAndroid)
		}
		if(This pointList == null)
			This pointList = LinkedList<FloatPoint2D> new()
		This pointList clear()
		this positions = gc_malloc(Float size * this pointCount * 2) as Float*
		for(i in 0..this pointCount) {
			this positions[2 * i] = 0
			this positions[2 * i + 1] = 0
		}
	}
	draw: func (transform: FloatTransform2D, screenSize: IntSize2D) {
		origo := FloatPoint2D new(transform g + screenSize width / 4, transform h + screenSize height / 4)
		transformedPosition := origo
		This pointList add(transformedPosition)
		if(This pointList size > this pointCount) {
			This pointList removeAt(0)
		}
		this program setUniform("screenWidth", screenSize width)
		this program setUniform("screenHeight", screenSize height)
		this program use()
		for(i in 0..This pointList size) {
			this positions[2 * i] = This pointList[i] x / (screenSize width / 2)
			this positions[2 * i + 1] = This pointList[i] y / (screenSize height / 2)
		}
		glLineWidth(1.5f)
		glBindVertexArray(0);
		glEnableVertexAttribArray(0)
		glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, this positions)
		glDrawArrays(GL_LINE_STRIP, 0, This pointList size)
		glDisableVertexAttribArray(0)
	}
}
