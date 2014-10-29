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
	OpenGLES3MapDefault defaultVertexSource =
		"#version 300 es\n
		precision highp float;\n
		uniform mat3 transform;\n
		uniform int imageWidth;\n
		uniform int imageHeight;\n
		uniform int screenWidth;\n
		uniform int screenHeight;\n
		layout(location = 0) in vec2 vertexPosition;\n
		layout(location = 1) in vec2 textureCoordinate;\n
		out vec2 fragmentTextureCoordinate;\n
		void main() {\n
			vec3 scaledQuadPosition = vec3(float(imageWidth) / 2.0f * vertexPosition.x, float(imageHeight) / 2.0f * vertexPosition.y, 1);\n
			vec3 transformedPosition = transform * scaledQuadPosition;\n
			transformedPosition.xy /= transformedPosition.z; \n
			mat4 projectionMatrix = transpose(mat4(2.0f / float(screenWidth), 0, 0, 0, 0, 2.0f / float(screenHeight), 0, 0, 0, 0, -1, 0, 0, 0, 0, 1));\n
			fragmentTextureCoordinate = textureCoordinate;\n
			gl_Position = projectionMatrix * vec4(transformedPosition, 1);\n
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
	OpenGLES3MapBgrToBgra  fragmentSource =
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
	OpenGLES3MapUv fragmentSource =
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
	OpenGLES3MapLines vertexSource =
		"#version 300 es\n
		precision highp float;\n
		layout(location = 0) in vec2 vertexPosition;\n
		void main() {\n
			gl_Position = vec4(vertexPosition.x, -vertexPosition.y, 0, 1);\n
		}\n";
	OpenGLES3MapLines fragmentSource =
		"#version 300 es\n
		precision highp float;\n
		uniform vec3 color;\n
		out vec4 outColor;\n
		void main() {\n
			outColor = vec4(color.r, color.g, color.b, 1.0f);\n
		}\n";
	OpenGLES3MapPyramidGeneration fragmentSource =
	"#version 300 es\n
	precision highp float;\n
	uniform sampler2D texture0;\n
	in vec2 fragmentTextureCoordinate;\n
	uniform float height;\n
	out vec3 outColor;\n
	vec2 makeCoordsFor(float max, float stepsize, float level, vec2 coordinate) {\n
		float increase = 0.0;\n
		for (float i = 0.0; i <= max; i = i + stepsize) {\n
			increase = increase + (level / height);\n
		}\n
		return vec2(coordinate.x * level - trunc(coordinate.x * level), coordinate.y * level * 2.0 - trunc(coordinate.y * level * 2.0) + increase);\n
	}\n
	void main() {\n
		if ((0.0 <= fragmentTextureCoordinate.y) && (fragmentTextureCoordinate.y <= 0.25) ) {\n
			outColor = texture(texture0, makeCoordsFor(1.0, 0.5, 2.0, fragmentTextureCoordinate)).rgb;\n
		}\n
		else if ((0.25 <= fragmentTextureCoordinate.y) && (fragmentTextureCoordinate.y <= 0.375 )) {\n
			outColor = texture(texture0, makeCoordsFor(1.0, 0.25, 4.0, fragmentTextureCoordinate)).rgb;\n
		}\n
		else if ((0.375 <= fragmentTextureCoordinate.y) && (fragmentTextureCoordinate.y <= 0.4375)) {\n
			outColor = texture(texture0, makeCoordsFor(1.0, 0.125, 8.0, fragmentTextureCoordinate)).rgb;\n
		}\n
		else {\n
			outColor = vec3(0.0,0.0,0.0);\n
		}\n
	}\n";
}
