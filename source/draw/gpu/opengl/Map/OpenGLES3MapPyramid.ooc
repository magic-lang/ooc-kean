use ooc-math
import OpenGLES3Map
OpenGLES3MapPyramidGeneration: abstract class extends OpenGLES3MapDefault {
	pyramidFraction: Float { get set }
	pyramidCoefficient: Float { get set }
	originalHeight: Int { get set }
	init: func (fragmentSource: String) {
		super(fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("pyramidFraction", this pyramidFraction)
				this _program setUniform("pyramidCoefficient", this pyramidCoefficient)
				this _program setUniform("originalHeight", this originalHeight)
				})
			}
		}
OpenGLES3MapPyramidGenerationDefault: class extends OpenGLES3MapPyramidGeneration {
	init: func { super(This fragmentSource) }
	fragmentSource: static String ="
	#version 300 es\n
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
}
OpenGLES3MapPyramidGenerationMipmap: class extends OpenGLES3MapPyramidGeneration {
	init: func { super(This fragmentSource) }
	fragmentSource: static String ="
	#version 300 es\n
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
}
