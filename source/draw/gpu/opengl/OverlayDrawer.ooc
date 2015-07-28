//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
use ooc-collections
use ooc-draw-gpu
use ooc-opengl
import structs/LinkedList
import OpenGLES3/Lines
OpenGLES3MapLines: class extends OpenGLES3MapDefault {
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
	init: func (context: GpuContext) { super(This vertexSource, This fragmentSource, context) }
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
OverlayDrawer: class {
	linesShader: OpenGLES3MapLines
	pointsShader: OpenGLES3MapPoints
	init: func (context: GpuContext){
		this linesShader = OpenGLES3MapLines new(context)
		this pointsShader = OpenGLES3MapPoints new(context)
		this pointsShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this pointsShader pointSize = 5.0f
	}
	free: func {
		this linesShader free()
		this pointsShader free()
		super()
	}
	drawLines: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer as Float*
		this linesShader color = FloatPoint3D new(0.0f, 0.0f, 0.0f)
		this linesShader model = FloatTransform3D identity
		this linesShader view = FloatTransform3D identity
		this linesShader projection = projection
		this linesShader use()
		Lines draw(positions, pointList count, 2, 3.5f)
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader use()
		Lines draw(positions, pointList count, 2, 1.5f)
	}
	drawBox: func (box: FloatBox2D, projection: FloatTransform3D) {
		positions: Float[10]
		positions[0] = box leftTop x
		positions[1] = box leftTop y
		positions[2] = box rightTop x
		positions[3] = box rightTop y
		positions[4] = box rightBottom x
		positions[5] = box rightBottom y
		positions[6] = box leftBottom x
		positions[7] = box leftBottom y
		positions[8] = box leftTop x
		positions[9] = box leftTop y
		this linesShader color = FloatPoint3D new(1.0f, 1.0f, 1.0f)
		this linesShader model = FloatTransform3D identity
		this linesShader view = FloatTransform3D identity
		this linesShader projection = projection
		this linesShader use()
		Lines draw(positions[0]&, 5, 2, 1.5f)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, projection: FloatTransform3D) {
		positions := pointList pointer
		this pointsShader use()
		this pointsShader projection = projection
		Points draw(positions, pointList count, 2)
	}
}
