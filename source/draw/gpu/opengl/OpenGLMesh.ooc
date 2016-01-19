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

use ooc-geometry
use draw-gpu
import OpenGLContext
import backend/GLVertexArrayObject

version(!gpuOff) {
OpenGLMesh: class extends GpuMesh {
	_backend: GLVertexArrayObject
	init: func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[], context: OpenGLContext) {
		this _backend = context backend createVertexArrayObject(vertices, textureCoordinates)
	}
	free: override func {
		this _backend free()
		super()
	}
	draw: override func { this _backend draw() }
}
}
