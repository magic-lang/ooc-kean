/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

 use geometry

version(!gpuOff) {
TextureType: enum {
	Monochrome
	Rgba
	Rgb
	Uv
	External
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
	_size: IntVector2D
	_type: TextureType
	_target: UInt
	backend ::= this _backend
	size ::= this _size

	init: func (=_type, =_size)
	generateMipmap: abstract func
	bind: abstract func (unit: UInt)
	unbind: abstract func
	upload: abstract func (pixels: Pointer, stride: Int)
	setMagFilter: abstract func (interpolation: InterpolationType)
	setMinFilter: abstract func (interpolation: InterpolationType)
}
}
