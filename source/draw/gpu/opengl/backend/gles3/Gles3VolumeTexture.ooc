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

use geometry
use base
import include/gles3
import ../GLVolumeTexture
import Gles3Debug

version(!gpuOff) {
Gles3VolumeTexture: class extends GLVolumeTexture {
	_backend: UInt
	_size: IntVector3D
	backend ::= this _backend
	size ::= this _size

	init: func (=_size, pixels: UInt8*) {
		version(debugGL) { validateStart("VolumeTexture init") }
		glGenTextures(1, _backend&)
		glBindTexture(GL_TEXTURE_3D, _backend)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE)
		glTexImage3D(GL_TEXTURE_3D, 0, GL_R8, this size x, this size y, this size z, 0, GL_RED, GL_UNSIGNED_BYTE, pixels)
		version(debugGL) { validateEnd("VolumeTexture init") }
	}
	free: override func {
		version(debugGL) { validateStart("VolumeTexture free") }
		glDeleteTextures(1, _backend&)
		version(debugGL) { validateEnd("VolumeTexture free") }
		super()
	}
	bind: override func (unit: UInt) {
		version(debugGL) { validateStart("VolumeTexture bind") }
		glActiveTexture(GL_TEXTURE0 + unit)
		glBindTexture(GL_TEXTURE_3D, this _backend)
		version(debugGL) { validateEnd("VolumeTexture bind") }
	}
	unbind: override func {
		version(debugGL) { validateStart("VolumeTexture unbind") }
		glBindTexture(GL_TEXTURE_3D, 0)
		version(debugGL) { validateEnd("VolumeTexture unbind") }
	}
	upload: override func (pixels: UInt8*) {
		version(debugGL) { validateStart("VolumeTexture upload") }
		glBindTexture(GL_TEXTURE_3D, this _backend)
		glTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, 0, this size x, this size y, this size z, GL_RED, GL_UNSIGNED_BYTE, pixels)
		this unbind()
		version(debugGL) { validateEnd("VolumeTexture upload") }
	}
}
}
