//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import OpenGLES3/ShaderProgram
import ImageProcessor

SimpleProcessor: class extends ImageProcessor {

simpleVertexSource: String = "#version 300 es\n
    layout(location = 0) in vec2 vertexPosition;\n
  layout(location = 1) in vec2 texCoord;\n
  out vec2 texCoords;\n
    void main() {\n
  	 mat4 projectionMatrix = transpose(mat4(9.0f/16.0f, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1));\n
  	 texCoords = texCoord;\n
        gl_Position = projectionMatrix*vec4(vertexPosition, 0, 1);\n
  }\n";

simpleFragmentSource: String = "#version 300 es\n
  uniform sampler2D frameSampler;\n
  in vec2 texCoords;
    out vec4 outColor;\n
    void main() {\n
      outColor = texture(frameSampler, texCoords).rgba;\n
    }\n";

  init: func () {
    this program = ShaderProgram new(simpleVertexSource, simpleFragmentSource)
    this program compile()
  }

  use: func () {
    program use()
    program setUniform("frameSampler" as String, 0)
  }
}
