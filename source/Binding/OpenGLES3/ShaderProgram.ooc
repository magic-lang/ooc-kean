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

import gles


ShaderProgram: class {
  backend: UInt
  vertexSource: String
  fragmentSource: String

  init: func (vertexSource: String, fragmentSource: String) {
    this vertexSource = vertexSource
    this fragmentSource = fragmentSource
  }

  use: func {
    glUseProgram(backend)
  }

  dispose: func() {
    glDeleteProgram(backend)
  }

  setUniform: func (name: String, value: UInt) {
    glUniform1i(glGetUniformLocation(this backend, name), value)
  }

  _compileShader: func(source: String, shaderID: UInt) {
    glShaderSource(shaderID, 1, source toCString()&, null)

    glCompileShader(shaderID)
    "Compiling shader:" println()
    source println()
    success: Int
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, success&)

    if(!success){
      "Shader compilation failed:" println()
      logSize: Int = 0
      glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
      compileLog := gc_malloc(logSize * Char size) as Char*
      length: Int
      glGetShaderInfoLog(shaderID, logSize, length&, compileLog)
      compileLog toString() println()
      //raise("Shader compilation failed: %s" compileLog)
    }
  }
  __compileShaders: func(vertexSource: String, fragmentSource: String) {
    vertexShaderID := glCreateShader(GL_VERTEX_SHADER)
    fragmentShaderID := glCreateShader(GL_FRAGMENT_SHADER)

    _compileShader(vertexSource, vertexShaderID)
    _compileShader(fragmentSource, fragmentShaderID)

    this backend = glCreateProgram()

    glAttachShader(backend, vertexShaderID)
    glAttachShader(backend, fragmentShaderID)
    glLinkProgram(backend)

    glDetachShader(backend, vertexShaderID)
    glDetachShader(backend, fragmentShaderID)

    glDeleteShader(vertexShaderID)
    glDeleteShader(fragmentShaderID)
  }
  compile: func() {
    __compileShaders(this vertexSource, this fragmentSource)
  }

}
