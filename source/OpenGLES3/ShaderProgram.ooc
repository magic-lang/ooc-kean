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
import lib/gles

ShaderProgram: class {
  _backend: UInt
  init: func
  use: func {
    glUseProgram(this _backend)
  }
  dispose: func {
    glDeleteProgram(this _backend)
  }
  setUniform: func ~Int (name: String, value: Int) {
    glUniform1i(glGetUniformLocation(this _backend, name), value)
  }
  setUniform: func ~Float (name: String, value: Float) {
    glUniform1f(glGetUniformLocation(this _backend, name), value)
  }
  setUniform: func ~Matrix3x3(name: String, value: FloatTransform2D) {
    glUniformMatrix3fv(glGetUniformLocation(this _backend, name), 1, 0, value& as Float*)
  }
  _compileShader: func(source: String, shaderID: UInt) -> Bool {
    glShaderSource(shaderID, 1, (source toCString())&, null)
    glCompileShader(shaderID)

    //"Compiling shader:" println()
    //source println()
    success: Int
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, success&)
    if(!success){
      logSize: Int = 0
      glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
      compileLog := gc_malloc(logSize * Char size) as Char*
      length: Int
      glGetShaderInfoLog(shaderID, logSize, length&, compileLog)
      compileLog toString() println()
      raise("Shader compilation failed")
      gc_free(compileLog)
    }
    success != 0
  }
  _compileShaders: func(vertexSource: String, fragmentSource: String) -> Bool {
    vertexShaderID := glCreateShader(GL_VERTEX_SHADER)
    fragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER)

    success := _compileShader(vertexSource, vertexShaderID)
    success = success && _compileShader(fragmentSource, fragmentShaderID)

    if(success) {
      this _backend = glCreateProgram()

      glAttachShader(this _backend, vertexShaderID)
      glAttachShader(this _backend, fragmentShaderID)
      glLinkProgram(this _backend)

      glDetachShader(this _backend, vertexShaderID)
      glDetachShader(this _backend, fragmentShaderID)

      glDeleteShader(vertexShaderID)
      glDeleteShader(fragmentShaderID)
    }
    success
  }
  create: static func (vertexSource: String, fragmentSource: String) -> This {
    result := This new()
    result _compileShaders(vertexSource, fragmentSource) ? result : null
  }

}
