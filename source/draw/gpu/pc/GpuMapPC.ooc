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

use ooc-opengl

setShaderSources: func {
	OpenGLES3MapDefault vertexSource =
		"#version 300 es\n
		precision highp float;\n
		uniform float invertY;\n
		layout(location = 0) in vec2 vertexPosition;\n
		layout(location = 1) in vec2 textureCoordinate;\n
		out vec2 fragmentTextureCoordinate;\n
		void main() {\n
			fragmentTextureCoordinate = textureCoordinate;\n
			gl_Position = vec4(vertexPosition.x, invertY * vertexPosition.y, -1, 1);\n
		}\n";
	OpenGLES3MapTransform vertexSource =
		"#version 300 es\n
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
		}\n";
	OpenGLES3MapOverlay fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		out float outColor;\n
		void main() {\n
			outColor = 0.0f;\n
		}\n";
	OpenGLES3MapBgr fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec3 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rgb;\n
		}\n";
	OpenGLES3MapBgrToBgra fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			outColor = vec4(texture(texture0, fragmentTextureCoordinate).rgb, 1.0f);\n
		}\n";
	OpenGLES3MapBgra fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec3 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rgb;\n
		}\n";
	OpenGLES3MapMonochrome fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).r;\n
		}\n";
	OpenGLES3MapMonochromeTransform fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).r;\n
		}\n";
	OpenGLES3MapUv fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec2 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rg;\n
		}\n";
	OpenGLES3MapUvTransform fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec2 outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).rg;\n
		}\n";
	OpenGLES3MapMonochromeToBgra fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			float colorSample = texture(texture0, fragmentTextureCoordinate).r;\n
			outColor = vec4(colorSample, colorSample, colorSample, 1.0f);\n
		}\n";
	OpenGLES3MapYuvPlanarToBgra fragmentSource =
		"#version 300 es\n
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
	OpenGLES3MapYuvSemiplanarToBgra fragmentSource =
		"#version 300 es\n
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
			outColor = YuvToRgba(vec4(y, uv.g - 0.5f, uv.r - 0.5f, 1.0f));\n
		}\n";
	OpenGLES3MapYuvSemiplanarToBgraTransform fragmentSource =
		"#version 300 es\n
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
			outColor = YuvToRgba(vec4(y, uv.g - 0.5f, uv.r - 0.5f, 1.0f));\n
		}\n";
	OpenGLES3MapPackMonochrome fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform int imageWidth;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			vec2 offsetTexCoords = fragmentTextureCoordinate - vec2(1.5f / float(imageWidth), 0);\n
			vec2 texelOffset = vec2(1.0f / float(imageWidth), 0);\n
			float r = texture(texture0, offsetTexCoords).x;\n
			float g = texture(texture0, offsetTexCoords + texelOffset).x;\n
			float b = texture(texture0, offsetTexCoords + 2.0f*texelOffset).x;\n
			float a = texture(texture0, offsetTexCoords + 3.0f*texelOffset).x;\n
			outColor = vec4(r, g, b, a);\n
		}\n";
	OpenGLES3MapPackUv fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform int imageWidth;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			vec2 offsetTexCoords = fragmentTextureCoordinate - vec2(1.5f / float(imageWidth), 0);\n
			vec2 texelOffset = vec2(1.0f / float(imageWidth), 0);\n
			vec2 rg = texture(texture0, offsetTexCoords).rg;\n
			vec2 ba = texture(texture0, offsetTexCoords + texelOffset).rg;\n
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);\n
		}\n";
	OpenGLES3MapLines fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform vec3 color;\n
		out vec4 outColor;\n
		void main() {\n
			outColor = vec4(color.r, color.g, color.b, 1.0f);\n
		}\n";
	OpenGLES3MapPoints vertexSource =
		"#version 300 es\n
		precision highp float;\n
		uniform float pointSize;\n
		layout(location = 0) in vec2 vertexPosition;\n
		void main() {\n
			gl_PointSize = pointSize;\n
			gl_Position = vec4(vertexPosition.x, vertexPosition.y, 0, 1);\n
		}\n";
	OpenGLES3MapPoints fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform vec3 color;\n
		out vec4 outColor;\n
		void main() {\n
			outColor = vec4(color.r, color.g, color.b, 1.0f);\n
		}\n";
	OpenGLES3MapPyramidGenerationDefault fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform float pyramidFraction;\n
		uniform float pyramidCoefficient;\n
		uniform int originalHeight;\n
		in vec2 fragmentTextureCoordinate;\n
		out float outColor;\n
		void main() {\n
			float level = floor(max(pyramidCoefficient * fragmentTextureCoordinate.y - 2.0f, 1.0f));\n
			float sampleDistanceX = pow(2.0f, level);\n
			float sampleDistanceY = pyramidFraction * sampleDistanceX * sampleDistanceX;\n
			float scaledX = sampleDistanceX * fragmentTextureCoordinate.x;\n
			float yOffset = floor(scaledX) * sampleDistanceX / float(originalHeight);\n
			vec2 transformedCoords = vec2(fract(scaledX), fract(fragmentTextureCoordinate.y * sampleDistanceY) + yOffset);\n
			outColor = texture(texture0, transformedCoords).r;\n
		}\n";
	OpenGLES3MapPyramidGenerationMipmap fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform float pyramidFraction;\n
		uniform float pyramidCoefficient;\n
		uniform int originalHeight;\n
		in vec2 fragmentTextureCoordinate;\n
		out float outColor;\n
		void main() {\n
			float level = floor(max(pyramidCoefficient * fragmentTextureCoordinate.y - 2.0f, 1.0f));\n
			float sampleDistanceX = pow(2.0f, level);\n
			float sampleDistanceY = pyramidFraction * sampleDistanceX * sampleDistanceX;\n
			float scaledX = sampleDistanceX * fragmentTextureCoordinate.x;\n
			float yOffset = floor(scaledX) * sampleDistanceX / float(originalHeight);\n
			vec2 transformedCoords = vec2(fract(scaledX), fract(fragmentTextureCoordinate.y * sampleDistanceY) + yOffset);\n
			outColor = textureLod(texture0, transformedCoords, level).r;\n
		}\n";
	OpenGLES3MapPackMonochrome1080p fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			float xCoord = 4.0f * fragmentTextureCoordinate.x - 1.5f / 1920.0f;\n
			float texelHeight = 1.0f / 1080.0f;\n
			float yCoord = fragmentTextureCoordinate.y - 1.5f / 1080.0f + floor(xCoord) * texelHeight;\n
			xCoord = fract(xCoord);\n
			vec2 transformedCoords = vec2(xCoord, yCoord);\n
			vec2 texelOffset = vec2(1.0f / 1920.0f, 0);\n
			float r = texture(texture0, transformedCoords).x;\n
			float g = texture(texture0, transformedCoords + texelOffset).x;\n
			float b = texture(texture0, transformedCoords + 2.0f*texelOffset).x;\n
			float a = texture(texture0, transformedCoords + 3.0f*texelOffset).x;\n
			outColor = vec4(r, g, b, a);\n
		}\n";
	OpenGLES3MapPackUv1080p fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			float xCoord = 4.0f * fragmentTextureCoordinate.x - 0.5f / 960.0f;\n
			float texelHeight = 1.0f / 540.0f;\n
			float yCoord = fragmentTextureCoordinate.y - 1.5f / 540.0f + floor(xCoord) * texelHeight;\n
			xCoord = fract(xCoord);\n
			vec2 transformedCoords = vec2(xCoord, yCoord);\n
			vec2 texelOffset = vec2(1.0f / 960.0f, 0);\n
			vec2 rg = texture(texture0, transformedCoords).rg;\n
			vec2 ba = texture(texture0, transformedCoords + texelOffset).rg;\n
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);\n
		}\n";
	OpenGLES3MapBlend fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		in vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			outColor = texture(texture0, fragmentTextureCoordinate).r/3.0f;
		}\n"
	}
