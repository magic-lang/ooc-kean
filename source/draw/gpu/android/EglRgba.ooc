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

use ooc-draw-gpu
use ooc-math
use ooc-opengl
use ooc-base
import EGLImage/eglimage
EglRgba: class extends GpuTexture {
	_texture: Texture
	texture: Texture { get { this _texture } }
	_id: Int
	id: Int { get { this _id } }
	_stride: Int
	stride: Int { get { this _stride } }
	_size: IntSize2D
	size: IntSize2D { get { this size } }
	_channels := 4
	init: func (eglDisplay: Pointer, size: IntSize2D, pixels: Pointer = null, write: Int = 0) {
		this _texture = Texture create(TextureType rgba, size width, size height, size width * this _channels, null, false)
		this _size = size
		DebugPrint print("Allocating EGL Image")
		this _id = createEGLImage(size width, size height, eglDisplay, write)
		this _stride = getStride(this _id) * this _channels
		if (pixels != null) {
			pointer := this write()
			memcpy(pointer, pixels, size width * size height * this _channels)
			this unlock()
		}
	}
	dispose: func {
		this _texture dispose()
		destroyEGLImage(this id)
	}
	setMagFilter: func (linear: Bool)
	upload: func (pixels: Pointer, stride: Int) {
		pointer := this write()
		memcpy(pointer, pixels, this size width * this size height * this _channels)
		this unlock()
	}
	generateMipmap: func
	bind: func (unit: UInt)
	unbind: func
	read: func -> UInt8* { readPixels(this id) as UInt8* }
	write: func -> UInt8* { writePixels(this id) as UInt8* }
	unlock: func { unlockPixels(this id) }
	isPadded: func -> Bool { this _stride > this _size width * this _channels }
	disposeAll: static func { destroyAll() }
}
