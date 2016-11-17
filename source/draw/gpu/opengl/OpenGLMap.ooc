/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
use draw-gpu
use collections
import backend/GLShaderProgram
import OpenGLContext, OpenGLPacked, OpenGLVolumeMonochrome

version(!gpuOff) {
OpenGLMap: class extends Map {
	_vertexSource: String
	_fragmentSource: String
	_program: GLShaderProgram = null
	_context: OpenGLContext
	init: func (=_vertexSource, =_fragmentSource, =_context) {
		super()
		if (this _vertexSource == null || this _fragmentSource == null)
			Debug error("Vertex or fragment shader source not set")
		this _program = this _context _backend createShaderProgram(this _vertexSource, this _fragmentSource)
	}
	init: func ~defaultVertex (fragmentSource: String, context: OpenGLContext) { this init(slurp("shaders/default.vert"), fragmentSource, context) }
	free: override func {
		this _program free()
		super()
	}
	useProgram: override func (forbiddenInput: Pointer, positionTransform, textureTransform: FloatTransform3D) {
		this _program useProgram()
		textureCount := 0
		action := func (key: String, value: Object) {
			program := this _program
			if (value instanceOf(Cell)) {
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
					case ColorRgb => color := cell as Cell<ColorRgb> get(); program setUniform(key, color r as Float / 255, color g as Float / 255, color b as Float / 255)
					case ColorRgba => color := cell as Cell<ColorRgba> get(); program setUniform(key, color r as Float / 255, color g as Float / 255, color b as Float / 255, color a as Float / 255)
					case ColorUv => color := cell as Cell<ColorUv> get(); program setUniform(key, color u as Float / 255, color v as Float / 255)
					case ColorYuv => color := cell as Cell<ColorYuv> get(); program setUniform(key, color y as Float / 255, color u as Float / 255, color v as Float / 255)
					case ColorYuva => color := cell as Cell<ColorYuva> get(); program setUniform(key, color y as Float / 255, color u as Float / 255, color v as Float / 255, color a as Float / 255)
					case => Debug error("Invalid cover type in OpenGLMap use!")
				}
			} else
				match (value) {
					case image: OpenGLPacked =>
						version(safe)
							if (forbiddenInput != null && (forbiddenInput as Pointer) == (image as Pointer))
								Debug error("Input image " + key + " is also the target.")
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
							case => Debug error("Invalid Vector type in OpenGLMap use")
						}
					case => Debug error("Invalid object type in OpenGLMap useProgram: %s" format(value class name))
				}
		}
		this apply(action)
		(action as Closure) free()
	}
}

OpenGLMapTransform: class extends OpenGLMap {
	init: func (fragmentSource: String, context: OpenGLContext) { super(This vertexSource, fragmentSource, context) }
	useProgram: override func (forbiddenInput: Pointer, positionTransform: FloatTransform3D, textureTransform: FloatTransform3D) {
		this add("transform", positionTransform)
		this add("textureTransform", textureTransform)
		super(forbiddenInput, positionTransform, textureTransform)
	}
	vertexSource: static String = slurp("shaders/transform.vert")
}
}
