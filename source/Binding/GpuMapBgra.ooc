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

use ooc-math
import OpenGLES3/ShaderProgram
import GpuMap

GpuMapBgra: class extends GpuMap {
program: ShaderProgram
instance: static This

bgraFragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D frameSampler;\n
  in vec2 texCoords;
  out vec4 outColor;\n
  void main() {\n
    outColor = texture(frameSampler, texCoords).rgba;\n
  }\n";

  init: func () {
    this program = ShaderProgram new(defaultVertexSource, bgraFragmentSource)
    this program compile()
  }

  getInstance: static func -> This {
    if(!(This instance)) {
      This instance = This new()
    }
    This instance
  }

  use: func (transform: FloatTransform2D) {
    this program use()
    this program setUniformi("frameSampler", 0)
    this program setUniformMatrix3fv("transform", transform& as Float*, 9, 0)
  }

}
