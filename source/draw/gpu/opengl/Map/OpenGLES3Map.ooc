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
	_context: GpuContext
	init: func (vertexSource: String, fragmentSource: String, context: GpuContext) {
		super()
		this _vertexSource = vertexSource
		this _fragmentSource = fragmentSource
		this _context = context
		this _program = ShaderProgram[context getMaxContexts()] new()
		if (vertexSource == null || fragmentSource == null)
			Debug raise("Vertex or fragment shader source not set")
	}
	free: override func {
		for (i in 0..this _context getMaxContexts()) {
			if (this _program[i] != null)
				this _program[i] free()
		}
		this _program free()
		super()
	}
	use: override func {
		currentIndex := this _context getCurrentIndex()
		if (this _program[currentIndex] == null)
			this _program[currentIndex] = ShaderProgram create(this _vertexSource, this _fragmentSource)
		this _program[currentIndex] use()
	}
}
OpenGLES3MapDefault: abstract class extends OpenGLES3Map {
	init: func (fragmentSource: String, context: GpuContext) { super(This vertexSource, fragmentSource, context) }
	vertexSource: static String ="
		#version 300 es
		precision highp float;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate;
		void main() {
			vec4 position = vec4(vertexPosition.x, vertexPosition.y, 0, 1);
			fragmentTextureCoordinate = textureCoordinate;
			gl_Position = position;
		}"
}
OpenGLES3MapDefaultTexture: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext, fragmentSource: String)
	init: func ~default (context: GpuContext) { this init(This fragmentSource, context) }
	use: override func {
		super()
		this program setUniform("texture0", 0)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			outColor = texture(texture0, fragmentTextureCoordinate).rgba;
		}"
}
OpenGLES3MapTransform: abstract class extends OpenGLES3Map {
	init: func (fragmentSource: String, context: GpuContext) { super(This vertexSource, fragmentSource, context) }
	use: override func {
		super()
		finalTransform := this projection * this view * this model
		this program setUniform("transform", finalTransform)
		this program setUniform("textureTransform", this textureTransform)
	}
	vertexSource: static String ="
		#version 300 es
		precision highp float;
		uniform mat4 transform;
		uniform mat4 textureTransform;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate;
		void main() {
			vec4 position = vec4(vertexPosition.x, vertexPosition.y, 0, 1);
			vec4 transformedPosition = transform * position;
			vec4 texCoord = (textureTransform * vec4(textureCoordinate, 1, 1));
			fragmentTextureCoordinate = texCoord.xy;
			gl_Position = transformedPosition;
		}"
}
OpenGLES3MapTransformTexture: class extends OpenGLES3MapTransform {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			outColor = texture(texture0, fragmentTextureCoordinate).rgba;
		}"
}
OpenGLES3MapMonochromeToBgra: class extends OpenGLES3MapDefaultTexture {
	init: func (context: GpuContext) { super(This customFragmentSource, context) }
	customFragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			float colorSample = texture(texture0, fragmentTextureCoordinate).r;
			outColor = vec4(colorSample, colorSample, colorSample, 1.0f);
		}"
}
OpenGLES3MapYuvPlanarToBgra: class extends OpenGLES3MapTransform {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		this program setUniform("texture0", 0)
		this program setUniform("texture1", 1)
		this program setUniform("texture2", 2)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform sampler2D texture1;
		uniform sampler2D texture2;
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		// Convert yuva to rgba
		vec4 YuvToRgba(vec4 t)
		{
			mat4 matrix = mat4(1, 1, 1, 0,
				-0.000001218894189, -0.344135678165337, 1.772000066073816, 0,
				1.401999588657340, -0.714136155581812, 0.000000406298063, 0,
				0, 0, 0, 1);
				return matrix * t;
		}
		void main() {
			float y = texture(texture0, fragmentTextureCoordinate).r;
			float u = texture(texture1, fragmentTextureCoordinate).r;
			float v = texture(texture2, fragmentTextureCoordinate).r;
			outColor = YuvToRgba(vec4(y, v - 0.5f, u - 0.5f, 1.0f));
		}"
}
OpenGLES3MapYuvSemiplanarToBgra: class extends OpenGLES3MapTransform {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		this program setUniform("texture0", 0)
		this program setUniform("texture1", 1)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform sampler2D texture0;
		uniform sampler2D texture1;
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		// Convert yuva to rgba
		vec4 YuvToRgba(vec4 t)
		{
			mat4 matrix = mat4(1, 1, 1, 0,
				-0.000001218894189, -0.344135678165337, 1.772000066073816, 0,
				1.401999588657340, -0.714136155581812, 0.000000406298063, 0,
				0, 0, 0, 1);
				return matrix * t;
		}
		void main() {
			float y = texture(texture0, fragmentTextureCoordinate).r;
			vec2 uv = texture(texture1, fragmentTextureCoordinate).rg;
			outColor = YuvToRgba(vec4(y, uv.r - 0.5f, uv.g - 0.5f, 1.0f));
		}"
}
OpenGLES3MapLines: class extends OpenGLES3MapTransform {
	color: FloatPoint3D { get set }
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		this program setUniform("color", this color)
	}
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform vec3 color;
		out vec4 outColor;
		void main() {
			outColor = vec4(color.r, color.g, color.b, 1.0f);
		}"
}
OpenGLES3MapPoints: class extends OpenGLES3Map {
	color: FloatPoint3D { get set }
	pointSize: Float { get set }
	projection: FloatTransform3D { get set }
	init: func (context: GpuContext) {
		this pointSize = 5.0f
		this color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		super(This vertexSource, This fragmentSource, context)
	}
	use: override func {
		super()
		this program setUniform("color", this color)
		this program setUniform("pointSize", this pointSize)
		this program setUniform("transform", this projection)
	}
	vertexSource: static String ="
		#version 300 es
		precision highp float;
		uniform float pointSize;
		uniform mat4 transform;
		layout(location = 0) in vec2 vertexPosition;
		void main() {
			gl_PointSize = pointSize;
			gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
		}"
	fragmentSource: static String ="
		#version 300 es
		precision highp float;
		uniform vec3 color;
		out vec4 outColor;
		void main() {
			outColor = vec4(color.r, color.g, color.b, 1.0f);
		}"
}
