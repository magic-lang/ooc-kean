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
	setUniform: override func ~Int (name: String, value: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int") }
		glUniform1i(glGetUniformLocation(this _backend, name), value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Int name:%s value:%d" format(name, value)) }
	}
	setUniform: override func ~IntPoint2D (name: String, value: IntPoint2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntPoint2D") }
		glUniform2i(glGetUniformLocation(this _backend, name), value x, value y)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntPoint2D") }
	}
	setUniform: override func ~IntPoint3D (name: String, value: IntPoint3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntPoint3D") }
		glUniform3i(glGetUniformLocation(this _backend, name), value x, value y, value z)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntPoint3D") }
	}
	setUniform: override func ~IntSize2D (name: String, value: IntSize2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntSize2D") }
		glUniform2i(glGetUniformLocation(this _backend, name), value width, value height)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntSize2D") }
	}
	setUniform: override func ~IntSize3D (name: String, value: IntSize3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntSize3D") }
		glUniform3i(glGetUniformLocation(this _backend, name), value width, value height, value depth)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntSize3D") }
	}
	setUniform: override func ~IntArray (name: String, value: Int*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntArray") }
		glUniform1iv(glGetUniformLocation(this _backend, name), count, value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~IntArray") }
	}
	setUniform: override func ~Float (name: String, value: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float") }
		glUniform1f(glGetUniformLocation(this _backend, name), value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Float") }
	}
	setUniform: override func ~FloatPoint2D (name: String, value: FloatPoint2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint2D") }
		glUniform2f(glGetUniformLocation(this _backend, name), value x, value y)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint2D") }
	}
	setUniform: override func ~FloatPoint3D (name: String, value: FloatPoint3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint3D") }
		glUniform3f(glGetUniformLocation(this _backend, name), value x, value y, value z)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint3D") }
	}
	setUniform: override func ~FloatPoint4D (name: String, value: FloatPoint4D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatPoint4D") }
		glUniform4f(glGetUniformLocation(this _backend, name), value x, value y, value z, value w)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatPoint4D") }
	}
	setUniform: override func ~ColorBgr (name: String, value: ColorBgr) {
		version(debugGL) { validateStart("ShaderProgram setUniform~ColorBgr") }
		glUniform3f(glGetUniformLocation(this _backend, name), (value blue as Float) / 255.0f, (value green as Float) / 255.0f, (value red as Float) / 255.0f)
		version(debugGL) { validateEnd("ShaderProgram setUniform~ColorBgr") }
	}
	setUniform: override func ~ColorBgra (name: String, value: ColorBgra) {
		version(debugGL) { validateStart("ShaderProgram setUniform~ColorBgra") }
		glUniform4f(glGetUniformLocation(this _backend, name), (value bgr blue as Float) / 255.0f, (value bgr green as Float) / 255.0f, (value bgr red as Float) / 255.0f, (value alpha as Float) / 255.0f)
		version(debugGL) { validateEnd("ShaderProgram setUniform~ColorBgra") }
	}
	setUniform: override func ~ColorUv (name: String, value: ColorUv) {
		version(debugGL) { validateStart("ShaderProgram setUniform~ColorUv") }
		glUniform2f(glGetUniformLocation(this _backend, name), (value u as Float) / 255.0f, (value v as Float) / 255.0f)
		version(debugGL) { validateEnd("ShaderProgram setUniform~ColorUv") }
	}
	setUniform: override func ~ColorYuv (name: String, value: ColorYuv) {
		version(debugGL) { validateStart("ShaderProgram setUniform~ColorYuv") }
		glUniform3f(glGetUniformLocation(this _backend, name), (value y as Float) / 255.0f, (value u as Float) / 255.0f, (value v as Float) / 255.0f)
		version(debugGL) { validateEnd("ShaderProgram setUniform~ColorYuv") }
	}
	setUniform: override func ~ColorYuva (name: String, value: ColorYuva) {
		version(debugGL) { validateStart("ShaderProgram setUniform~ColorYuva") }
		glUniform4f(glGetUniformLocation(this _backend, name), (value yuv y as Float) / 255.0f, (value yuv u as Float) / 255.0f, (value yuv v as Float) / 255.0f, (value alpha as Float) / 255.0f)
		version(debugGL) { validateEnd("ShaderProgram setUniform~ColorYuva") }
	}
	setUniform: override func ~FloatSize2D (name: String, value: FloatSize2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatSize2D") }
		glUniform2f(glGetUniformLocation(this _backend, name), value width, value height)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatSize2D") }
	}
	setUniform: override func ~FloatSize3D (name: String, value: FloatSize3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatSize3D") }
		glUniform3f(glGetUniformLocation(this _backend, name), value width, value height, value depth)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatSize3D") }
	}
	setUniform: override func ~FloatArray (name: String, value: Float*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatArray") }
		glUniform1fv(glGetUniformLocation(this _backend, name), count, value)
		version(debugGL) { validateEnd("ShaderProgram setUniform~FloatArray") }
	}
	setUniform: override func ~Matrix3x3 (name: String, value: FloatTransform2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Matrix3x3") }
		glUniformMatrix3fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd("ShaderProgram setUniform~Matrix3x3") }
	}
	setUniform: override func ~Matrix4x4 (name: String, value: FloatTransform3D) {
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
