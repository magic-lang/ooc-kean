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

use ooc-math
use ooc-draw-gpu
import OpenGLMap
import ../OpenGLContext

version(!gpuOff) {
OpenGLMapPack: abstract class extends OpenGLMap {
	imageWidth: Int { get set }
	channels: Int { get set }
	transform: FloatTransform3D
	init: func (vertexSource: String, fragmentSource: String, context: OpenGLContext) {
		super(vertexSource, fragmentSource, context)
		this channels = 1
		this transform = FloatTransform3D createScaling(1.0f, -1.0f, 1.0f)
	}
	use: override func {
		super()
		this program setUniform("texture0", 0)
		texelOffset := 1.0f / this imageWidth
		this program setUniform("texelOffset", texelOffset)
		offset := (2.0f / channels - 0.5f) / this imageWidth
		this program setUniform("xOffset", offset)
		this program setUniform("transform", this transform)
	}
}
OpenGLMapPackMonochrome: class extends OpenGLMapPack {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	vertexSource: static String = "#version 300 es
		precision mediump float;
		uniform mat4 transform;
		uniform float xOffset;
		uniform float texelOffset;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate[4];
		void main() {
			fragmentTextureCoordinate[0] = textureCoordinate + vec2(-xOffset, 0);
			fragmentTextureCoordinate[1] = textureCoordinate + vec2(texelOffset - xOffset, 0);
			fragmentTextureCoordinate[2] = textureCoordinate + vec2(2.0f * texelOffset - xOffset, 0);
			fragmentTextureCoordinate[3] = textureCoordinate + vec2(3.0f * texelOffset - xOffset, 0);
			gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
		}
		"
	fragmentSource: static String = "#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		in highp vec2 fragmentTextureCoordinate[4];
		out vec4 outColor;
		void main() {
			float r = texture(texture0, fragmentTextureCoordinate[0]).x;
			float g = texture(texture0, fragmentTextureCoordinate[1]).x;
			float b = texture(texture0, fragmentTextureCoordinate[2]).x;
			float a = texture(texture0, fragmentTextureCoordinate[3]).x;
			outColor = vec4(r, g, b, a);
		}
		"
}
OpenGLMapPackUv: class extends OpenGLMapPack {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	vertexSource: static String = "#version 300 es
		precision mediump float;
		uniform mat4 transform;
		uniform float xOffset;
		uniform float texelOffset;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate[2];
		void main() {
			fragmentTextureCoordinate[0] = textureCoordinate + vec2(-xOffset, 0);
			fragmentTextureCoordinate[1] = textureCoordinate + vec2(texelOffset - xOffset, 0);
			gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
		}
		"
	fragmentSource: static String = "#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		in highp vec2 fragmentTextureCoordinate[2];
		out vec4 outColor;
		void main() {
			vec2 rg = texture(texture0, fragmentTextureCoordinate[0]).rg;
			vec2 ba = texture(texture0, fragmentTextureCoordinate[1]).rg;
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);
		}
		"
}
OpenGLMapUnpack: abstract class extends OpenGLMap {
	sourceSize: IntSize2D { get set }
	targetSize: IntSize2D { get set }
	transform: FloatTransform3D { get set }
	init: func (fragmentSource: String, context: OpenGLContext) {
		super(This vertexSource, fragmentSource, context)
		this transform = FloatTransform3D identity
	}
	use: override func {
		super()
		this program setUniform("texture0", 0)
		this program setUniform("targetWidth", this targetSize width)
		this program setUniform("transform", this transform)
	}
	vertexSource: static String = "#version 300 es
		precision mediump float;
		uniform float startY;
		uniform float scaleX;
		uniform float scaleY;
		uniform mat4 transform;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec4 fragmentTextureCoordinate;
		void main() {
			fragmentTextureCoordinate = vec4(scaleX * textureCoordinate.x, startY + scaleY * textureCoordinate.y, textureCoordinate);
			gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
		}
		"
}
OpenGLMapUnpackRgbaToMonochrome: class extends OpenGLMapUnpack {
	init: func (context: OpenGLContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (4 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		scaleY := targetSize height as Float / sourceSize height
		this program setUniform("scaleY", scaleY)
		this program setUniform("startY", 0.0f)
	}
	fragmentSource: static String = "#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		uniform int targetWidth;
		in highp vec4 fragmentTextureCoordinate;
		out float outColor;
		void main() {
			int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 4;
			outColor = texture(texture0, fragmentTextureCoordinate.xy)[pixelIndex];
		}
		"
}
OpenGLMapUnpackRgbaToUv: class extends OpenGLMapUnpack {
	init: func (context: OpenGLContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (2 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		startY := (sourceSize height - targetSize height) as Float / sourceSize height
		this program setUniform("startY", startY)
		scaleY := 1.0f - startY
		this program setUniform("scaleY", scaleY)
	}
	fragmentSource: static String = "#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		uniform int targetWidth;
		in highp vec4 fragmentTextureCoordinate;
		out vec2 outColor;
		void main() {
			int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 2;
			vec4 texel = texture(texture0, fragmentTextureCoordinate.xy);
			vec2 mask = vec2(float(1 - pixelIndex), float(pixelIndex));
			outColor = vec2(mask.x * texel.r + mask.y * texel.b, mask.x * texel.g + mask.y * texel.a);
		}
		"
}
}
