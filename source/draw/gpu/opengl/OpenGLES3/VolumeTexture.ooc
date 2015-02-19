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
use ooc-base
import include/gles
import Context
VolumeTexture: class {
	_backend: UInt
	backend: UInt { get { this _backend } }
	width, height, depth: UInt

	init: func (=width, =height, =depth, pixels: UInt8*) {
		glGenTextures(1, _backend&)
		glBindTexture(GL_TEXTURE_3D, _backend)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE)
		glTexImage3D(GL_TEXTURE_3D, 0, GL_R8, this width, this height, this depth, 0, GL_RED, GL_UNSIGNED_BYTE, pixels)
	}
	free: func {
		glDeleteTextures(1, _backend&)
		super()
	}
	bind: func (unit: UInt) {
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(GL_TEXTURE_3D, this _backend)
	}
	unbind: func { glBindTexture(GL_TEXTURE_3D, 0) }
	upload: func (pixels: UInt8*) {
		glBindTexture(GL_TEXTURE_3D, this _backend)
		glTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, 0, this width, this height, this depth, GL_RED, GL_UNSIGNED_BYTE, pixels)
		this unbind()
	}
}
