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
use ooc-draw-gpu
import OpenGLES3/Texture

OpenGLES3Texture: class extends GpuTexture {
	backend: Texture { get { this _backend as Texture } }
	init: func (texture: Texture) { super(texture, IntSize2D new(texture width, texture height)) }
	generateMipmap: func { this backend generateMipmap() }
	setMagFilter: func (linear: Bool) {
		if (linear)
			this backend setMagFilter(InterpolationType Linear)
		else
			this backend setMagFilter(InterpolationType Nearest)
	}
	free: func {
		this backend free()
		super()
	}
	bind: func (unit: UInt) { this backend bind(unit) }
	unbind: func { this backend unbind() }
	upload: func(pointer: UInt8*, stride: UInt) { this backend upload(pointer, stride) }
	createBgr: static func (size: IntSize2D, stride: UInt, data: Pointer) -> This {
		This new(Texture create(TextureType bgr, size width, size height, stride, data))
	}
	createBgra: static func (size: IntSize2D, stride: UInt, data: Pointer) -> This {
		This new(Texture create(TextureType bgra, size width, size height, stride, data))
	}
	createMonochrome: static func (size: IntSize2D, stride: UInt, data: Pointer) -> This {
		This new(Texture create(TextureType monochrome, size width, size height, stride, data))
	}
	createUv: static func (size: IntSize2D, stride: UInt, data: Pointer) -> This {
		This new(Texture create(TextureType uv, size width, size height, stride, data))
	}
}
