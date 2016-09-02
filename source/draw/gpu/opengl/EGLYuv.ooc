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
	_nativeBuffer: Pointer
	nativeBuffer ::= this _nativeBuffer
	init: func (_buffer: GraphicBuffer, context: OpenGLContext) {
		super(EGLImage create(TextureType External, _buffer size, _buffer nativeBuffer, context backend), 3, context)
	}
	free: override func {
		super()
	}
	toRasterDefault: override func -> RasterImage { Debug error("toRasterDefault unimplemented for EGLYuv"); null }
	toRasterDefault: override func ~target (target: RasterImage) { Debug error("toRasterDefault~target unimplemented for EGLYuv"); null }
}
}
