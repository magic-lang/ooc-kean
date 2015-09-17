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

GLShaderProgram: abstract class {
	use: abstract func
	setUniform: abstract func ~Array (name: String, array: Float*, count: Int)
	setUniform: abstract func ~Int (name: String, value: Int)
	setUniform: abstract func ~Int2 (name: String, a, b: Int)
	setUniform: abstract func ~Int3 (name: String, a, b, c: Int)
	setUniform: abstract func ~Int4 (name: String, a, b, c, d: Int)
	setUniform: abstract func ~IntPoint2D (name: String, value: IntPoint2D)
	setUniform: abstract func ~IntSize2D (name: String, value: IntSize2D)
	setUniform: abstract func ~IntPoint3D (name: String, value: IntPoint3D)
	setUniform: abstract func ~IntSize3D (name: String, value: IntSize3D)
	setUniform: abstract func ~Float (name: String, value: Float)
	setUniform: abstract func ~Float2 (name: String, a, b: Float)
	setUniform: abstract func ~Float3 (name: String, a, b, c: Float)
	setUniform: abstract func ~Float4 (name: String, a, b, c, d: Float)
	setUniform: abstract func ~FloatPoint2D (name: String, value: FloatPoint2D)
	setUniform: abstract func ~FloatSize2D (name: String, value: FloatSize2D)
	setUniform: abstract func ~FloatPoint3D (name: String, value: FloatPoint3D)
	setUniform: abstract func ~FloatSize3D (name: String, value: FloatSize3D)
	setUniform: abstract func ~IntArray (name: String, count: Int, value: Int*)
	setUniform: abstract func ~FloatArray (name: String, count: Int, value: Float*)
	setUniform: abstract func ~Matrix4x4arr (name: String, value: Float*)
	setUniform: abstract func ~Matrix3x3 (name: String, value: FloatTransform2D)
	setUniform: abstract func ~Matrix4x4 (name: String, value: FloatTransform3D)
	setUniform: abstract func ~Vector3 (name: String, value: FloatPoint3D)
}
