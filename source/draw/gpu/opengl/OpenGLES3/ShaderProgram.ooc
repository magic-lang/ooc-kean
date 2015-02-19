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
import include/gles, Debug

ShaderProgram: class {
	_backend: UInt
	init: func
	use: func {
		version(debugGL) { validateStart() }
		glUseProgram(this _backend)
		version(debugGL) { validateEnd("ShaderProgram use") }
	}
	free: func {
		version(debugGL) { validateStart() }
		glDeleteProgram(this _backend)
		version(debugGL) { validateEnd("ShaderProgram dispose") }
		super()
	}
	setUniform: func ~Array (name: String, array: Float*, count: Int) {
		version(debugGL) { validateStart() }
		glUniform1fv(glGetUniformLocation(this _backend, name), count, array)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Array") }
	}
	setUniform: func ~Int (name: String, value: Int) {
		version(debugGL) { validateStart() }
		glUniform1i(glGetUniformLocation(this _backend, name), value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Int") }
	}
	setUniform: func ~IntSize2D (name: String, value: IntSize2D) {
		version(debugGL) { validateStart() }
		glUniform2i(glGetUniformLocation(this _backend, name), value width, value height)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint2D") }
	}
	setUniform: func ~Float (name: String, value: Float) {
		version(debugGL) { validateStart() }
		glUniform1f(glGetUniformLocation(this _backend, name), value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Float") }
	}
	setUniform: func ~FloatPoint2D (name: String, value: FloatPoint2D) {
		version(debugGL) { validateStart() }
		glUniform2f(glGetUniformLocation(this _backend, name), value x, value y)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint2D") }
	}
	setUniform: func ~FloatSize2D (name: String, value: FloatSize2D) {
		version(debugGL) { validateStart() }
		glUniform2f(glGetUniformLocation(this _backend, name), value width, value height)
		version(debugGL) { validateEnd("ShaderProgram setUniform~SizePoint2D") }
	}
	setUniform: func ~FloatPoint3D (name: String, value: FloatPoint3D) {
		version(debugGL) { validateStart() }
		glUniform3f(glGetUniformLocation(this _backend, name), value x, value y, value z)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint3D") }
	}
	setUniform: func ~FloatSize3D (name: String, value: FloatSize3D) {
		version(debugGL) { validateStart() }
		glUniform3f(glGetUniformLocation(this _backend, name), value width, value height, value depth)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint3D") }
	}
	setUniform: func ~FloatArray (name: String, count: Int, value: Float*) {
		version(debugGL) { validateStart() }
		glUniform1fv(glGetUniformLocation(this _backend, name), count, value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatArray") }
	}
	setUniform: func ~Matrix4x4arr (name: String, value: Float*) {
		version(debugGL) { validateStart() }
		glUniformMatrix4fv(glGetUniformLocation(this _backend, name), 1, 0, value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix4x4arr") }
	}
	setUniform: func ~Matrix3x3 (name: String, value: FloatTransform2D) {
		version(debugGL) { validateStart() }
		glUniformMatrix3fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix3x3") }
	}
	setUniform: func ~Matrix4x4 (name: String, value: FloatTransform3D) {
		version(debugGL) { validateStart() }
		array := value to4x4()
		glUniformMatrix4fv(glGetUniformLocation(this _backend, name), 1, 0, array)
		gc_free(array)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix4x4") }
	}
	setUniform: func ~Vector3(name: String, value: FloatPoint3D) {
		version(debugGL) { validateStart() }
		glUniform3fv(glGetUniformLocation(this _backend, name), 1, value& as Float*)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Vector3") }
	}
	_compileShader: func(source: String, shaderID: UInt) -> Bool {
		version(debugGL) { validateStart() }
		glShaderSource(shaderID, 1, (source toCString())&, null)
		glCompileShader(shaderID)

		success: Int
		glGetShaderiv(shaderID, GL_COMPILE_STATUS, success&)
		if (!success){
			source println()
			logSize: Int = 0
			glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
			compileLog := gc_malloc(logSize * Char size) as Char*
			length: Int
			glGetShaderInfoLog(shaderID, logSize, length&, compileLog)
			compileLog toString() println()
			raise("Shader compilation failed")
			gc_free(compileLog)
		}
		version(debugGL) { validateEnd("ShaderProgram _compileShader") }
		success != 0
	}
	_compileShaders: func(vertexSource: String, fragmentSource: String) -> Bool {
		version(debugGL) { validateStart() }
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
	create: static func (vertexSource: String, fragmentSource: String) -> This {
		version(debugGL) { validateStart() }
		result := This new()
		result = result _compileShaders(vertexSource, fragmentSource) ? result : null
		version(debugGL) { validateEnd("ShaderProgram create") }
		result
	}

}
