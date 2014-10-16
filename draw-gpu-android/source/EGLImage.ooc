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

use ooc-opengl
use ooc-math
import egl/eglimage
EGLImage: class {
	texture: Texture { get set }
	id: Int { get set }
	init: func (eglDisplay: Pointer, type: TextureType, size: IntSize2D, pixels := null) {
		this texture = Texture create(type, size width, size height, size width, pixels, false)
		this id = createEGLImage(eglDisplay)
	}
	dispose: func {
		this texture dispose()
		destroyEGLImage(this id)
	}
	lock: func -> Pointer {
		result := lockPixels(this id)
		result
	}
	unlock: func {
		unlockPixels(this id)
	}
}
