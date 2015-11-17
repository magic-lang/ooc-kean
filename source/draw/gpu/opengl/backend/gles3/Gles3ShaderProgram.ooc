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

use ooc-math
use ooc-draw
import include/gles3
import ../GLShaderProgram
import Gles3Debug

version(!gpuOff) {
Gles3ShaderProgram: class extends GLShaderProgram {
	_backend: UInt

	init: func
	free: override func {
		version(debugGL) { validateStart("ShaderProgram dispose") }
		glDeleteProgram(this _backend)
		version(debugGL) { validateEnd("ShaderProgram dispose") }
		super()
	}
	use: override func {
		version(debugGL) { validateStart("ShaderProgram use") }
		glUseProgram(this _backend)
		version(debugGL) { validateEnd("ShaderProgram use") }
	}
	setUniform: override func ~Int (name: String, x: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int") }
		glUniform1i(glGetUniformLocation(this _backend, name), x)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Int name:%s value:%d" format(name, x)) }
	}
	setUniform: override func ~Int2 (name: String, x, y: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntPoint2D") }
		glUniform2i(glGetUniformLocation(this _backend, name), x, y)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntPoint2D") }
	}
	setUniform: override func ~Int3 (name: String, x, y, z: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntPoint3D") }
		glUniform3i(glGetUniformLocation(this _backend, name), x, y, z)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntPoint3D") }
	}
	setUniform: override func ~Int4 (name: String, x, y, z, w: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntSize2D") }
		glUniform4i(glGetUniformLocation(this _backend, name), x, y, z, w)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntSize2D") }
	}
	setUniform: override func ~IntArray (name: String, values: Int*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntArray") }
		glUniform1iv(glGetUniformLocation(this _backend, name), count, values)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntArray") }
	}
	setUniform: override func ~Float (name: String, x: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float") }
		glUniform1f(glGetUniformLocation(this _backend, name), x)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Float") }
	}
	setUniform: override func ~Float2 (name: String, x, y: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint2D") }
		glUniform2f(glGetUniformLocation(this _backend, name), x, y)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint2D") }
	}
	setUniform: override func ~Float3 (name: String, x, y, z: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint3D") }
		glUniform3f(glGetUniformLocation(this _backend, name), x, y, z)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint3D") }
	}
	setUniform: override func ~Float4 (name: String, x, y, z, w: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint4D") }
		glUniform4f(glGetUniformLocation(this _backend, name), x, y, z, w)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint4D") }
	}
	setUniform: override func ~FloatArray (name: String, values: Float*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatArray") }
		glUniform1fv(glGetUniformLocation(this _backend, name), count, values)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatArray") }
	}
	setUniform: override func ~FloatTransform2D (name: String, value: FloatTransform2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Matrix3x3") }
		glUniformMatrix3fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix3x3") }
	}
	setUniform: override func ~FloatTransform3D (name: String, value: FloatTransform3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Matrix4x4") }
		glUniformMatrix4fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix4x4") }
	}
	_compileShader: func (source: String, shaderID: UInt) -> Bool {
		version(debugGL) { validateStart("ShaderProgram _compileShader") }
		glShaderSource(shaderID, 1, source, null)
		glCompileShader(shaderID)

		success: Int
		glGetShaderiv(shaderID, GL_COMPILE_STATUS, success&)
		if (!success) {
			source println()
			logSize: Int = 0
			glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
			compileLog := gc_malloc(logSize * Char size) as CString
			length: Int
			glGetShaderInfoLog(shaderID, logSize, length&, compileLog)
			compileLogString := compileLog toString()
			compileLogString println()
			compileLogString free()
			gc_free(compileLog)
			raise("Shader compilation failed")
		}
		version(debugGL) { validateEnd("ShaderProgram _compileShader") }
		success != 0
	}
	_compileShaders: func (vertexSource, fragmentSource: String) -> Bool {
		version(debugGL) { validateStart("ShaderProgram _compileShaders") }
		vertexShaderID := glCreateShader(GL_VERTEX_SHADER)
		fragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER)
		success := _compileShader(vertexSource, vertexShaderID)
		success = success && _compileShader(fragmentSource, fragmentShaderID)

		if (success) {
			this _backend = glCreateProgram()

			glAttachShader(this _backend, vertexShaderID)
			glAttachShader(this _backend, fragmentShaderID)
			glLinkProgram(this _backend)

			glDetachShader(this _backend, vertexShaderID)
			glDetachShader(this _backend, fragmentShaderID)

			glDeleteShader(vertexShaderID)
			glDeleteShader(fragmentShaderID)
		}
		version(debugGL) { validateEnd("ShaderProgram _compileShaders") }
		success
	}
}
}
