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
  vertexSource: Char*
  fragmentSource: Char*

  init: func (vertexSource: Char*, fragmentSource: Char*) {
    this width = width
    this height = height
    this type = type
    this vertexSource = vertexSource
    this fragmentSource = fragmentSource
  }

  use: func {
    glUseProgram(backend)
  }

  dispose: func() {
    glDeleteProgram(backend)
  }

  _compileShader: func(source: Char*, shaderID: Int) {
    glShaderSource(shaderID, source&, NULL)
    glCompileShader(shaderID)

    success: Int
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &success)

    if(!success){
      logSize: Int = 0
      glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, logSize&)
      compileLog: Char[logSize]
      glGetShaderInfoLog(shaderID, logSize, null, compileLog)
      raise("Shader compilation failed: %s" compileLog)
    }
  }
  __compileShaders: func(vertexSource: Char*, fragmentSource: Char*) {
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
