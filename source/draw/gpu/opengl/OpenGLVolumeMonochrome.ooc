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
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-math
use ooc-draw
use ooc-draw-gpu
import backend/[GLVolumeTexture, GLContext]
import OpenGLContext

version(!gpuOff) {
OpenGLVolumeMonochrome: class {
	_backend: GLVolumeTexture
	init: func (size: IntSize3D, pixels: UInt8* = null, context: OpenGLContext) {
		this _backend = context backend createVolumeTexture(size, pixels)
	}
	upload: func (pixels: UInt8*) { this _backend upload(pixels) }
	free: override func {
		this _backend free()
		super()
	}
}
}
