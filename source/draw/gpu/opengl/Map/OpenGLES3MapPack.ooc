use ooc-math
use ooc-draw-gpu
import OpenGLES3Map
OpenGLES3MapPack: abstract class extends OpenGLES3MapDefault {
	imageWidth: Int { get set }
	init: func (fragmentSource: String, context: GpuContext) {
		super(fragmentSource, context, false,
			func {
				this program setUniform("texture0", 0)
				this program setUniform("imageWidth", this imageWidth)
			})
	}
}
OpenGLES3MapPackMonochrome: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform int imageWidth;\n
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			vec2 offsetTexCoords = fragmentTextureCoordinate - vec2(1.5f / float(imageWidth), 0);\n
			vec2 texelOffset = vec2(1.0f / float(imageWidth), 0);\n
			float r = texture(texture0, offsetTexCoords).x;\n
			float g = texture(texture0, offsetTexCoords + texelOffset).x;\n
			float b = texture(texture0, offsetTexCoords + 2.0f*texelOffset).x;\n
			float a = texture(texture0, offsetTexCoords + 3.0f*texelOffset).x;\n
			outColor = vec4(r, g, b, a);\n
		}\n"
}
OpenGLES3MapPackUv: class extends OpenGLES3MapPack {
	init: func (context: GpuContext) { super(This fragmentSource, context) }
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform int imageWidth;\n
		in highp vec2 fragmentTextureCoordinate;
		out vec4 outColor;\n
		void main() {\n
			vec2 offsetTexCoords = fragmentTextureCoordinate - vec2(0.5f / float(imageWidth), 0);\n
			vec2 texelOffset = vec2(1.0f / float(imageWidth), 0);\n
			vec2 rg = texture(texture0, offsetTexCoords).rg;\n
			vec2 ba = texture(texture0, offsetTexCoords + texelOffset).rg;\n
			outColor = vec4(rg.x, rg.y, ba.x, ba.y);\n
		}\n"
}
OpenGLES3MapUnpackRgbaToMonochrome: class extends OpenGLES3MapDefault {
	sourceSize: IntSize2D { get set }
	targetSize: IntSize2D { get set }
	init: func (context: GpuContext) {
		super(This fragmentSource, context, false, func {
			this program setUniform("texture0", 0)
			this program setUniform("sourceSize", this sourceSize)
			this program setUniform("targetSize", this targetSize)
		})
	}
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform ivec2 sourceSize;
		uniform ivec2 targetSize;
		in highp vec2 fragmentTextureCoordinate;
		out float outColor;\n
		void main() {\n
			int pixelIndex = int(float(targetSize.x) * fragmentTextureCoordinate.x) % 4;\n
			//Can this be moved to vertex shader?
			vec2 texCoords = vec2(fragmentTextureCoordinate.x, float(targetSize.y) * fragmentTextureCoordinate.y / float(sourceSize.y));
			if (pixelIndex == 0)\n
				outColor = texture(texture0, texCoords).r;\n
			else if (pixelIndex == 1)\n
				outColor = texture(texture0, texCoords).g;\n
			else if (pixelIndex == 2)\n
				outColor = texture(texture0, texCoords).b;\n
			else
				outColor = texture(texture0, texCoords).a;\n
		}\n"
}
OpenGLES3MapUnpackRgbaToUv: class extends OpenGLES3MapDefault {
	sourceSize: IntSize2D { get set }
	targetSize: IntSize2D { get set }
	init: func (context: GpuContext) {
		super(This fragmentSource, context, false, func {
			this program setUniform("texture0", 0)
			this program setUniform("sourceSize", this sourceSize)
			this program setUniform("targetWidth", this targetSize width)
			startY: Float = (sourceSize height - targetSize height) / sourceSize height as Float
			this program setUniform("startY", startY)
		})
	}
	fragmentSource: static String ="
		#version 300 es\n
		precision highp float;\n
		uniform sampler2D texture0;\n
		uniform int targetWidth;
		uniform highp float startY;
		in highp vec2 fragmentTextureCoordinate;
		out vec2 outColor;\n
		void main() {\n
			int pixelIndex = int(float(targetWidth) * fragmentTextureCoordinate.x) % 2;\n
			//Can this be moved to vertex shader?
			float yCoord = startY + (1.0f - startY) * fragmentTextureCoordinate.y;
			vec2 texCoords = vec2(fragmentTextureCoordinate.x, yCoord);
			if (pixelIndex == 0)\n
				outColor = vec2(texture(texture0, texCoords).r, texture(texture0, texCoords).g);\n
			else\n
				outColor = vec2(texture(texture0, texCoords).b, texture(texture0, texCoords).a);\n
		}\n"
}
