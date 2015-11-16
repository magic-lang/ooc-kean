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

use ooc-math
use ooc-draw

version(!gpuOff) {
GLShaderProgram: abstract class {
	use: abstract func
	setUniform: abstract func ~Int (name: String, value: Int)
	setUniform: abstract func ~IntPoint2D (name: String, value: IntPoint2D)
	setUniform: abstract func ~IntPoint3D (name: String, value: IntPoint3D)
	setUniform: abstract func ~IntSize2D (name: String, value: IntSize2D)
	setUniform: abstract func ~IntSize3D (name: String, value: IntSize3D)
	setUniform: abstract func ~IntArray (name: String, value: Int*, count: Int)
	setUniform: abstract func ~Float (name: String, value: Float)
	setUniform: abstract func ~FloatPoint2D (name: String, value: FloatPoint2D)
	setUniform: abstract func ~FloatPoint3D (name: String, value: FloatPoint3D)
	setUniform: abstract func ~FloatPoint4D (name: String, value: FloatPoint4D)
	setUniform: abstract func ~ColorBgr (name: String, value: ColorBgr)
	setUniform: abstract func ~ColorBgra (name: String, value: ColorBgra)
	setUniform: abstract func ~ColorUv (name: String, value: ColorUv)
	setUniform: abstract func ~ColorYuv (name: String, value: ColorYuv)
	setUniform: abstract func ~ColorYuva (name: String, value: ColorYuva)
	setUniform: abstract func ~FloatSize2D (name: String, value: FloatSize2D)
	setUniform: abstract func ~FloatSize3D (name: String, value: FloatSize3D)
	setUniform: abstract func ~FloatArray (name: String, value: Float*, count: Int)
	setUniform: abstract func ~Matrix3x3 (name: String, value: FloatTransform2D)
	setUniform: abstract func ~Matrix4x4 (name: String, value: FloatTransform3D)
}
}
