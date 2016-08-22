/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use base
use concurrent
import GraphicBuffer, OpenGLContext, OpenGLPacked
import backend/[GLTexture, GLContext, EGLImage]

version(!gpuOff) {
EGLYuv: class extends OpenGLPacked {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	init: func (=_buffer, context: OpenGLContext) {
		super(EGLImage create(TextureType External, this _buffer size, this _buffer nativeBuffer, context backend), 3, context)
	}
	free: override func {
		this _recyclable = false
		super()
	}
	toRasterDefault: override func -> RasterImage { Debug error("toRasterDefault unimplemented for EGLYuv"); null }
	toRasterDefault: override func ~target (target: RasterImage) { Debug error("toRasterDefault~target unimplemented for EGLYuv"); null }
}
}
