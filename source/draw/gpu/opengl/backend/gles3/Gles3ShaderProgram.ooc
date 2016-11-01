/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
import external/gles3
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
	useProgram: override func {
		version(debugGL) { validateStart("ShaderProgram useProgram") }
		glUseProgram(this _backend)
		version(debugGL) { validateEnd("ShaderProgram useProgram") }
	}
	setUniform: override func ~Int (name: String, x: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int") }
		glUniform1i(glGetUniformLocation(this _backend, name), x)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Int name:%s value:%d" format(name, x)) }
	}
	setUniform: override func ~Int2 (name: String, x, y: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int2") }
		glUniform2i(glGetUniformLocation(this _backend, name), x, y)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Int2 name:%s x=%d y=%d" format(name, x, y)) }
	}
	setUniform: override func ~Int3 (name: String, x, y, z: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int3") }
		glUniform3i(glGetUniformLocation(this _backend, name), x, y, z)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Int3 name:%s x=%d y=%d z=%d" format(name, x, y, z)) }
	}
	setUniform: override func ~Int4 (name: String, x, y, z, w: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Int4") }
		glUniform4i(glGetUniformLocation(this _backend, name), x, y, z, w)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Int4 name:%s x=%d y=%d z=%d w=%d" format(name, x, y, z, w)) }
	}
	setUniform: override func ~IntArray (name: String, values: Int*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~IntArray") }
		glUniform1iv(glGetUniformLocation(this _backend, name), count, values)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~IntArray name:%s" format(name)) }
	}
	setUniform: override func ~Float (name: String, x: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float") }
		glUniform1f(glGetUniformLocation(this _backend, name), x)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Float name:%s x=%f" format(name, x)) }
	}
	setUniform: override func ~Float2 (name: String, x, y: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float2") }
		glUniform2f(glGetUniformLocation(this _backend, name), x, y)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Float2 name:%s x=%f y=%f" format(name, x, y)) }
	}
	setUniform: override func ~Float3 (name: String, x, y, z: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float3") }
		glUniform3f(glGetUniformLocation(this _backend, name), x, y, z)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Float3 name:%s x=%f y=%f z=%f" format(name, x, y, z)) }
	}
	setUniform: override func ~Float4 (name: String, x, y, z, w: Float) {
		version(debugGL) { validateStart("ShaderProgram setUniform~Float4") }
		glUniform4f(glGetUniformLocation(this _backend, name), x, y, z, w)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~Float4 name:%s x=%f y=%f z=%f w=%f" format(name, x, y, z, w)) }
	}
	setUniform: override func ~FloatArray (name: String, values: Float*, count: Int) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatArray") }
		glUniform1fv(glGetUniformLocation(this _backend, name), count, values)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~FloatArray name:%s" format(name)) }
	}
	setUniform: override func ~FloatTransform2D (name: String, value: FloatTransform2D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatTransform2D") }
		glUniformMatrix3fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~FloatTransform2D name:%s value: " format(name) & value toString()) }
	}
	setUniform: override func ~FloatTransform3D (name: String, value: FloatTransform3D) {
		version(debugGL) { validateStart("ShaderProgram setUniform~FloatTransform3D") }
		glUniformMatrix4fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
		version(debugGL) { validateEnd~free("ShaderProgram setUniform~FloatTransform3D name:%s value: " format(name) & value toString()) }
	}
	_compileShader: func (source: String, shaderID: UInt) -> Bool {
		version(debugGL) { validateStart("ShaderProgram _compileShader") }
		glShaderSource(shaderID, 1, source, null)
		glCompileShader(shaderID)

		success: Int
		glGetShaderiv(shaderID, GL_COMPILE_STATUS, success&)
		if (!success) {
			Debug print(source)
			logSize: Int = 0
			glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
			compileLog := calloc(logSize, Char size) as CString
			length: Int
			glGetShaderInfoLog(shaderID, logSize, length&, compileLog)
			Debug print~free(compileLog toString())
			memfree(compileLog)
			Debug error("Shader compilation failed")
		}
		version(debugGL) { validateEnd("ShaderProgram _compileShader") }
		success != 0
	}
	_compileShaders: func (vertexSource, fragmentSource: String) -> Bool {
		version(debugGL) { validateStart("ShaderProgram _compileShaders") }
		vertexShaderID := glCreateShader(GL_VERTEX_SHADER)
		fragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER)
		success := this _compileShader(vertexSource, vertexShaderID)
		success = success && this _compileShader(fragmentSource, fragmentShaderID)

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
