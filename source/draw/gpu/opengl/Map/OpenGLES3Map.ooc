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
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
use ooc-math
use ooc-draw-gpu

import OpenGLES3/ShaderProgram

OpenGLES3Map: abstract class extends GpuMap {
	_vertexSource: String
	_fragmentSource: String
	_program: ShaderProgram[]
	program: ShaderProgram { get { this _program[this _context getCurrentIndex()] } }
	_onUse: Func
	_context: GpuContext
	init: func (vertexSource: String, fragmentSource: String, context: GpuContext, onUse: Func) {
		this _vertexSource = vertexSource
		this _fragmentSource = fragmentSource
		this _onUse = onUse
		this _context = context
		this _program = ShaderProgram[context getMaxContexts()] new()
		if (vertexSource == null || fragmentSource == null) {
			DebugPrint print("Vertex or fragment shader source not set")
			raise("Vertex or fragment shader source not set")
		}
	}
	free: func {
		for (i in 0..this _context getMaxContexts()) {
			if (this _program[i] != null)
				this _program[i] free()
		}
		super()
	}
	use: func {
		currentIndex := this _context getCurrentIndex()
		if (this _program[currentIndex] == null)
			this _program[currentIndex] = ShaderProgram create(this _vertexSource, this _fragmentSource)
		this _program[currentIndex] use()
		this _onUse()
	}
}
OpenGLES3MapDefault: abstract class extends OpenGLES3Map {
	transform: FloatTransform2D { get set }
	init: func (fragmentSource: String, context: GpuContext, transform: Bool, onUse: Func) {
		useFunc := transform ?
			(func {
				onUse()
				reference: Float[16]
				this transform to3DTransformArray(reference[0]&)
				this program setUniform("transform", reference[0]&)
			}) : (func { onUse() })
		super(transform ? This vertexSourceTransform : This vertexSource, fragmentSource, context, useFunc)
	}
	vertexSource: static String ="
		#version 300 es\n
		precision highp float;\n
		layout(location = 0) in vec2 vertexPosition;\n
		layout(location = 1) in vec2 textureCoordinate;\n
		out vec2 fragmentTextureCoordinate;\n
		void main() {\n
			fragmentTextureCoordinate = textureCoordinate;\n
			gl_Position = vec4(vertexPosition.x, vertexPosition.y, -1, 1);\n
		}\n"
	vertexSourceTransform: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform mat4 transform;\n
		layout(location = 0) in vec2 vertexPosition;\n
		layout(location = 1) in vec2 textureCoordinate;\n
		out vec2 fragmentTextureCoordinate;\n
		void main() {\n
			vec4 position = vec4(vertexPosition.x, vertexPosition.y, 0, 1);\n
			vec4 transformedPosition = transform * position;\n
			fragmentTextureCoordinate = textureCoordinate;\n
			gl_Position = transformedPosition;\n
		}\n"
}
OpenGLES3MapBgr: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec3 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rgb;\n
		}\n"
}
OpenGLES3MapBgrToBgra: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			outColor = vec4(texture(texture0, fragmentTextureCoordinate).rgb, 1.0f);\n
		}\n"
}
OpenGLES3MapBgra: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rgba;\n
		}\n"
}
OpenGLES3MapMonochrome: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).r;\n
		}\n"
}
OpenGLES3MapMonochromeTransform: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).r;\n
		}\n"
}
OpenGLES3MapUv: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec2 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rg;\n
		}\n"
}
OpenGLES3MapMonochromeToBgra: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) { super(This fragmentSource, context, transform, func { this program setUniform("texture0", 0) }) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			float colorSample = texture(texture0, fragmentTextureCoordinate).r;\n
			outColor = vec4(colorSample, colorSample, colorSample, 1.0f);\n
		}\n"
}
OpenGLES3MapYuvPlanarToBgra: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) {
		super(This fragmentSource, context, transform,
			func {
				this program setUniform("texture0", 0)
				this program setUniform("texture1", 1)
				this program setUniform("texture2", 2)
			})
	}
	fragmentSource: static String ="
		#version 300 es\n
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
		}\n"
}
OpenGLES3MapYuvSemiplanarToBgra: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, transform := false) {
		super(This fragmentSource, context, transform,
			func {
				this program setUniform("texture0", 0)
				this program setUniform("texture1", 1)
			})
	}
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform sampler2D texture1;\n
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
			vec2 uv = texture(texture1, fragmentTextureCoordinate).rg;\n
			outColor = YuvToRgba(vec4(y, uv.r - 0.5f, uv.g - 0.5f, 1.0f));\n
		}\n"
}
