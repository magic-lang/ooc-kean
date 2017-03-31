/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use draw-gpu
import backend/[GLVolumeTexture, GLContext]
import OpenGLContext

OpenGLVolumeMonochrome: class {
	_backend: GLVolumeTexture
	init: func (size: IntVector3D, pixels: Byte* = null, context: OpenGLContext) {
		this _backend = context backend createVolumeTexture(size, pixels)
	}
	free: override func {
		this _backend free()
		super()
	}
	upload: func (pixels: Byte*) { this _backend upload(pixels) }
}
