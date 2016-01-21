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
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

use geometry
use draw

version(!gpuOff) {
GLShaderProgram: abstract class {
	use: abstract func
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
