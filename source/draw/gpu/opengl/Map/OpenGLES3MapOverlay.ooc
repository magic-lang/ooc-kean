use ooc-math
use ooc-draw-gpu
import OpenGLES3Map

OpenGLES3MapLines: class extends OpenGLES3MapTransform {
	color: FloatPoint3D { get set }
	init: func (context: GpuContext) {
		super(This fragmentSource, context,
			func {
				this program setUniform("color", this color)
				})
			}
			fragmentSource: static String ="
			#version 300 es\n
			precision highp float;\n
			uniform vec3 color;\n
			out vec4 outColor;\n
			void main() {\n
				outColor = vec4(color.r, color.g, color.b, 1.0f);\n
				}\n";
		}
OpenGLES3MapPoints: class extends OpenGLES3Map {
	color: FloatPoint3D { get set }
	pointSize: Float { get set }
	transform: FloatTransform2D { get set }
	init: func (context: GpuContext) {
		super(This vertexSource, This fragmentSource, context,
			func {
				this program setUniform("color", this color)
				this program setUniform("pointSize", this pointSize)
				//FIXME: Don't use heap array
				reference := (this transform) to3DTransformArray()
				this program setUniform("transform", reference)
				gc_free(reference)
				})
	}
	vertexSource: static String ="
	#version 300 es\n
	precision highp float;\n
	uniform float pointSize;\n
	uniform mat4 transform;\n
	layout(location = 0) in vec2 vertexPosition;\n
	void main() {\n
		gl_PointSize = pointSize;\n
		gl_Position = transform * vec4(vertexPosition.x, vertexPosition.y, 0, 1);\n
		}\n";
	fragmentSource: static String ="
	#version 300 es\n
	precision highp float;\n
	uniform vec3 color;\n
	out vec4 outColor;\n
	void main() {\n
		outColor = vec4(color.r, color.g, color.b, 1.0f);\n
		}\n";
}
OpenGLES3MapBlend: class extends OpenGLES3MapDefault {
	init: func (context: GpuContext) {
		super(This fragmentSource, context,
			func {
				this program setUniform("texture0", 0)
				})
			}
			fragmentSource: static String ="
			#version 300 es\n
			precision highp float;\n
			uniform sampler2D texture0;\n
			in vec2 fragmentTextureCoordinate;
			out float outColor;\n
			void main() {\n
				outColor = texture(texture0, fragmentTextureCoordinate).r;
				}\n"
		}
