/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import external/gles3
import ../GLVolumeTexture
import Gles3Debug

version(!gpuOff) {
Gles3VolumeTexture: class extends GLVolumeTexture {
	_backend: UInt
	_size: IntVector3D
	backend ::= this _backend
	size ::= this _size

	init: func (=_size, pixels: Byte*) {
		version(debugGL) { validateStart("VolumeTexture init") }
		glGenTextures(1, this _backend&)
		glBindTexture(GL_TEXTURE_3D, this _backend)
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
		glDeleteTextures(1, this _backend&)
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
	upload: override func (pixels: Byte*) {
		version(debugGL) { validateStart("VolumeTexture upload") }
		glBindTexture(GL_TEXTURE_3D, this _backend)
		glTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, 0, this size x, this size y, this size z, GL_RED, GL_UNSIGNED_BYTE, pixels)
		this unbind()
		version(debugGL) { validateEnd("VolumeTexture upload") }
	}
}
}
