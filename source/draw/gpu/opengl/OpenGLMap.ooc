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
use ooc-draw
use ooc-draw-gpu
use ooc-collections
import backend/GLShaderProgram
import OpenGLContext, OpenGLPacked, OpenGLVolumeMonochrome

version(!gpuOff) {
OpenGLMap: class extends GpuMap {
	_vertexSource: String
	_fragmentSource: String
	_program: GLShaderProgram[]
	_currentProgram: GLShaderProgram {
		get {
			index := this _context getCurrentIndex()
			result := this _program[index]
			if (result == null) {
				result = this _context _backend createShaderProgram(this _vertexSource, this _fragmentSource)
				this _program[index] = result
			}
			result
		}
	}
	_context: OpenGLContext
	init: func (vertexSource: String, fragmentSource: String, context: OpenGLContext) {
		super()
		this _vertexSource = vertexSource
		this _fragmentSource = fragmentSource
		this _context = context
		this _program = GLShaderProgram[context getMaxContexts()] new()
		if (vertexSource == null || fragmentSource == null)
			Debug raise("Vertex or fragment shader source not set")
	}
	free: override func {
		for (i in 0 .. this _context getMaxContexts()) {
			if (this _program[i] != null)
				this _program[i] free()
		}
		this _program free()
		super()
	}
	use: override func {
		this _currentProgram use()
		textureCount := 0
		action := func (key: String, value: Object) {
			program := this _currentProgram
			if (value instanceOf?(Cell)) {
				cell := value as Cell
				match (cell T) {
					case Int => program setUniform(key, cell as Cell<Int> get())
					case IntPoint2D => point := cell as Cell<IntPoint2D> get(); program setUniform(key, point x, point y)
					case IntPoint3D => point := cell as Cell<IntPoint3D> get(); program setUniform(key, point x, point y, point z)
					case IntVector2D => size := cell as Cell<IntVector2D> get(); program setUniform(key, size x, size y)
					case IntVector3D => size := cell as Cell<IntVector3D> get(); program setUniform(key, size x, size y, size z)
					case Float => program setUniform(key, cell as Cell<Float> get())
					case FloatPoint2D => point := cell as Cell<FloatPoint2D> get(); program setUniform(key, point x, point y)
					case FloatPoint3D => point := cell as Cell<FloatPoint3D> get(); program setUniform(key, point x, point y, point z)
					case FloatTuple4 => tuple := cell as Cell<FloatTuple4> get(); program setUniform(key, tuple a, tuple b, tuple c, tuple d)
					case FloatVector2D => size := cell as Cell<FloatVector2D> get(); program setUniform(key, size x, size y)
					case FloatVector3D => size := cell as Cell<FloatVector3D> get(); program setUniform(key, size x, size y, size z)
					case FloatTransform2D => program setUniform(key, cell as Cell<FloatTransform2D> get())
					case FloatTransform3D => program setUniform(key, cell as Cell<FloatTransform3D> get())
					case ColorBgr => color := cell as Cell<ColorBgr> get(); program setUniform(key, color red as Float / 255, color green as Float / 255, color blue as Float / 255)
					case ColorBgra => color := cell as Cell<ColorBgra> get(); program setUniform(key, color red as Float / 255, color green as Float / 255, color blue as Float / 255, color alpha as Float / 255)
					case ColorUv => color := cell as Cell<ColorUv> get(); program setUniform(key, color u as Float / 255, color v as Float / 255)
					case ColorYuv => color := cell as Cell<ColorYuv> get(); program setUniform(key, color y as Float / 255, color u as Float / 255, color v as Float / 255)
					case ColorYuva => color := cell as Cell<ColorYuva> get(); program setUniform(key, color yuv y as Float / 255, color yuv u as Float / 255, color yuv v as Float / 255, color alpha as Float / 255)
					case => Debug raise("Invalid cover type in OpenGLMap use!")
				}
			} else
				match (value) {
					case image: OpenGLPacked =>
						image backend bind(textureCount)
						program setUniform(key, textureCount)
						textureCount += 1
					case image: OpenGLVolumeMonochrome =>
						image _backend bind(textureCount)
						program setUniform(key, textureCount)
						textureCount += 1
					case vector: Vector =>
						match (vector T) {
							case Int => program setUniform(key, vector _backend as Int*, vector capacity)
							case Float => program setUniform(key, vector _backend as Float*, vector capacity)
							case => Debug raise("Invalid Vector type in OpenGLMap use")
						}
					case => Debug raise("Invalid object type in OpenGLMap use: %s" format(value class name))
				}
		}
		this apply(action)
		(action as Closure) free()
	}
	new: static func ~default (fragmentSource: String, context: OpenGLContext) -> This { OpenGLMapTransform new(fragmentSource, context) }
}
OpenGLMapMesh: class extends OpenGLMap {
	init: func (context: OpenGLContext) { super(This vertexSource, This fragmentSource, context) }
	use: override func {
		this add("projection", this projection)
		super()
	}
	vertexSource: static String = slurp("shaders/mesh.vert")
	fragmentSource: static String = slurp("shaders/mesh.frag")
}
OpenGLMapTransform: class extends OpenGLMap {
	init: func (fragmentSource: String, context: OpenGLContext) { super(This vertexSource, fragmentSource, context) }
	use: override func {
		finalTransform := this projection * this view * this model
		this add("transform", finalTransform)
		this add("textureTransform", this textureTransform)
		super()
	}
	vertexSource: static String = slurp("shaders/transform.vert")
}
}
