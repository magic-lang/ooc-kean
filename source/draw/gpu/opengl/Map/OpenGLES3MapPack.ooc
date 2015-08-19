use ooc-math
use ooc-draw-gpu
import OpenGLES3Map
OpenGLES3MapPack: abstract class extends OpenGLES3Map {
	imageWidth: Int { get set }
	channels: Int { get set }
	transform: FloatTransform3D { get set }
	init: func (fragmentSource: String, context: GpuContext) {
		super(This vertexSource, fragmentSource, context)
		this channels = 1
		this transform = FloatTransform3D identity
	}
	use: override func {
		super()
		this program setUniform("texture0", 0)
		offset := (2.0f / channels - 0.5f) / this imageWidth
		this program setUniform("offset", offset)
		this program setUniform("transform", this transform)
	}
	vertexSource: static String ="
		#version 300 es
		precision mediump float;
		uniform mat4 transform;
		uniform float offset;
		layout(location = 0) in vec2 vertexPosition;
		layout(location = 1) in vec2 textureCoordinate;
		out vec2 fragmentTextureCoordinate;
		void main() {
			fragmentTextureCoordinate = textureCoordinate - vec2(offset, 0);
			gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);
		}"
}
OpenGLES3MapPackMonochrome: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		texelOffset := 1.0f / this imageWidth
		this program setUniform("texelOffset", texelOffset)
	}
	fragmentSource: static String ="
		#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		uniform float texelOffset;
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			vec2 texelOffsetCoord = vec2(texelOffset, 0);
			float r = texture(texture0, fragmentTextureCoordinate).x;
			float g = texture(texture0, fragmentTextureCoordinate + texelOffsetCoord).x;
			float b = texture(texture0, fragmentTextureCoordinate + 2.0f*texelOffsetCoord).x;
			float a = texture(texture0, fragmentTextureCoordinate + 3.0f*texelOffsetCoord).x;
			outColor = vec4(r, g, b, a);
		}"
}
OpenGLES3MapPackUv: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		texelOffset := 1.0f / this imageWidth
		this program setUniform("texelOffset", texelOffset)
	}
	fragmentSource: static String ="
		#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		uniform float texelOffset;
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;
		void main() {
			vec2 texelOffsetCoord = vec2(texelOffset, 0);
			vec2 rg = texture(texture0, fragmentTextureCoordinate).rg;
			vec2 ba = texture(texture0, fragmentTextureCoordinate + texelOffsetCoord).rg;
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);
		}"
}
OpenGLES3MapUnpack: abstract class extends OpenGLES3Map {
	sourceSize: IntSize2D { get set }
	targetSize: IntSize2D { get set }
	transform: FloatTransform3D { get set }
	init: func (fragmentSource: String, context: GpuContext) {
		super(This vertexSource, fragmentSource, context)
		this transform = FloatTransform3D identity
	}
	use: override func {
		super()
		this program setUniform("texture0", 0)
		this program setUniform("targetWidth", this targetSize width)
		this program setUniform("transform", this transform)
	}
	vertexSource: static String ="
		#version 300 es
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
		}"
}
OpenGLES3MapUnpackRgbaToMonochrome: class extends OpenGLES3MapUnpack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (4 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		scaleY := targetSize height as Float / sourceSize height
		this program setUniform("scaleY", scaleY)
		this program setUniform("startY", 0.0f)
	}
	fragmentSource: static String ="
		#version 300 es
		precision mediump float;
		uniform sampler2D texture0;
		uniform int targetWidth;
		in highp vec4 fragmentTextureCoordinate;
		out float outColor;
		void main() {
			int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.z) % 4;
			outColor = texture(texture0, fragmentTextureCoordinate.xy)[pixelIndex];
		}"
}
OpenGLES3MapUnpackRgbaToUv: class extends OpenGLES3MapUnpack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	use: override func {
		super()
		scaleX := (this targetSize width as Float) / (2 * this sourceSize width)
		this program setUniform("scaleX", scaleX)
		startY := (sourceSize height - targetSize height) as Float / sourceSize height
		this program setUniform("startY", startY)
		scaleY := 1.0f - startY
		this program setUniform("scaleY", scaleY)
	}
	fragmentSource: static String ="
		#version 300 es
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
		}"
}
