//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This _program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This _program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this _program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
import OpenGLES3/ShaderProgram

GpuMap: abstract class {
  _program: ShaderProgram
  _onUse: Func

  init: func (vertexSource: String, fragmentSource: String, onUse: Func) {
    this _onUse = onUse;
    this _program = ShaderProgram create(vertexSource, fragmentSource)
  }

  use: func {
    this _program use()
    this _onUse()
  }
}

GpuMapDefault: abstract class extends GpuMap {
  transform: FloatTransform2D { get set }
  ratio: Float { get set }
  init: func (fragmentSource: String, onUse: Func) {
    super(This defaultVertexSource, fragmentSource,
      func {
        onUse()
        this _program setUniform("ratio", ratio)
        this _program setUniform("transform", transform)
      })
  }
  defaultVertexSource: static const String = "#version 300 es\n
  precision highp float;\n
  uniform mat3 transform;\n
  uniform float ratio;\n
  layout(location = 0) in vec2 vertexPosition;\n
  layout(location = 1) in vec2 textureCoordinate;\n
  out vec2 fragmentTextureCoordinate;\n
  void main() {\n
    vec3 transformedPosition = transform * vec3(vertexPosition, 0);\n
    mat4 projectionMatrix = transpose(mat4(1.0f / ratio, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1));\n
    fragmentTextureCoordinate = textureCoordinate;\n
    gl_Position = projectionMatrix * vec4(transformedPosition, 1);\n
  }\n";
}

GpuMapBgr: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  in vec2 fragmentTextureCoordinate;
  out vec3 outColor;\n
  void main() {\n
    outColor = texture(texture0, fragmentTextureCoordinate).rgb;\n
  }\n";
}

GpuMapBgrToBgra: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  in vec2 fragmentTextureCoordinate;
  out vec4 outColor;\n
  void main() {\n
    outColor = vec4(texture(texture0, fragmentTextureCoordinate).rgb, 1.0f);\n
  }\n";
}

GpuMapBgra: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  in vec2 fragmentTextureCoordinate;
  out vec3 outColor;\n
  void main() {\n
    outColor = texture(texture0, fragmentTextureCoordinate).rgb;\n
  }\n";
}

GpuMapMonochrome: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  in vec2 fragmentTextureCoordinate;
  out float outColor;\n
  void main() {\n
    outColor = texture(texture0, fragmentTextureCoordinate).r;\n
  }\n";
}

GpuMapMonochromeToBgra: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  in vec2 fragmentTextureCoordinate;
  out vec4 outColor;\n
  void main() {\n
    float colorSample = texture(texture0, fragmentTextureCoordinate).r;\n
    outColor = vec4(colorSample, colorSample, colorSample, 1.0f);\n
  }\n";
}

GpuMapYuvToBgra: class extends GpuMapDefault {
  init: func {
    super(This fragmentSource,
      func {
        this _program setUniform("texture0", 0)
        this _program setUniform("texture1", 1)
        this _program setUniform("texture2", 2)
      })
  }
fragmentSource: const static String = "#version 300 es\n
  precision highp float;\n
  uniform sampler2D texture0;\n
  uniform sampler2D texture1;\n
  uniform sampler2D texture2;\n
  in vec2 fragmentTextureCoordinate;
  out vec4 outColor;\n
  // Convert yuva to rgba
  vec4 YuvToRgba(vec4 t)
  {
    mat4 matrix = mat4(1, 1, 1, 0,
    -0.000001218894189, -0.344135678165337, 1.772000066073816, 0,
    1.401999588657340, -0.714136155581812, 0.000000406298063, 0,
    0, 0, 0, 1);
    return matrix * t;
  }
  void main() {\n
    float y = texture(texture0, fragmentTextureCoordinate).r;\n
    float u = texture(texture1, fragmentTextureCoordinate).r;\n
    float v = texture(texture2, fragmentTextureCoordinate).r;\n
    outColor = YuvToRgba(vec4(y, v - 0.5f, u - 0.5f, 1.0f));\n
  }\n";
}
