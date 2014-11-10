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
use ooc-opengl
import egl/eglimage
EglRgba: class extends Texture {
	_id: Int
	id: Int { get { this _id } }
	_stride: Int
	stride: Int { get { this _stride } }
	_size: IntSize2D
	size: IntSize2D { get }
	_channels := 4
	init: func (eglDisplay: Pointer, size: IntSize2D) {
		super(TextureType rgba, size width, size height)
		this _size = size
		this _generate(null, size width, false)
		//this _backend = Texture create(TextureType rgba, size width, size height, size width, null, false)
		this _id = createEGLImage(size width, size height, eglDisplay)
		this _stride = getStride(this _id) * this _channels
	}
	dispose: func {
		//this dispose()
		destroyEGLImage(this id)
	}
	uploadPixels: func(pixels: Pointer, stride: Int) {
		pointer := this lock()
		memcpy(pointer, pixels, this size width * this size height)
		this unlock()
	}
	lock: func -> UInt8* {
		result := lockPixels(this id) as UInt8*
		result
	}
	unlock: func {
		unlockPixels(this id)
	}
	isPadded: func -> Bool {
		this _stride > this _size width * this _channels
	}
	disposeAll: static func {
		destroyAll()
	}
}
