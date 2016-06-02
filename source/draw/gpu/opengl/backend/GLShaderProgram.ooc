/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw

version(!gpuOff) {
GLShaderProgram: abstract class {
	useProgram: abstract func
	setUniform: abstract func ~Int (name: String, x: Int)
	setUniform: abstract func ~Int2 (name: String, x, y: Int)
	setUniform: abstract func ~Int3 (name: String, x, y, z: Int)
	setUniform: abstract func ~Int4 (name: String, x, y, z, w: Int)
	setUniform: abstract func ~IntArray (name: String, values: Int*, count: Int)
	setUniform: abstract func ~Float (name: String, x: Float)
	setUniform: abstract func ~Float2 (name: String, x, y: Float)
	setUniform: abstract func ~Float3 (name: String, x, y, z: Float)
	setUniform: abstract func ~Float4 (name: String, x, y, z, w: Float)
	setUniform: abstract func ~FloatArray (name: String, values: Float*, count: Int)
	setUniform: abstract func ~FloatTransform2D (name: String, value: FloatTransform2D)
	setUniform: abstract func ~FloatTransform3D (name: String, value: FloatTransform3D)
}
}
