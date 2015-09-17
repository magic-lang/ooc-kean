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

TextureType: enum {
	monochrome
	rgba
	rgb
	bgr
	bgra
	uv
	yv12
}

InterpolationType: enum {
	Nearest
	Linear
	LinearMipmapNearest
	LinearMipmapLinear
	NearestMipmapNearest
	NearestMipmapLinear
}

GLTexture: abstract class {
	_backend: UInt
	backend: UInt { get { this _backend } }
	_size: IntSize2D
	size ::= this _size

	generateMipmap: abstract func
	bind: abstract func (unit: UInt)
	unbind: abstract func
	upload: abstract func (pixels: Pointer, stride: Int)
	setMagFilter: abstract func (interpolation: InterpolationType)
	setMinFilter: abstract func (interpolation: InterpolationType)
}
