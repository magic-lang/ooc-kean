/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
import GraphicBuffer, OpenGLContext, OpenGLRgba, AndroidContext
import backend/[GLTexture, GLContext, EGLImage]

version(!gpuOff) {
EGLRgba: class extends OpenGLRgba {
	_buffer: GraphicBuffer
	buffer ::= this _buffer
	init: func ~fromGraphicBuffer (=_buffer, context: OpenGLContext) {
		super(EGLImage create(TextureType Rgba, this _buffer size, this _buffer nativeBuffer, context backend), context)
	}
	init: func ~fromSize (size: IntVector2D, context: OpenGLContext) {
		this init(GraphicBuffer new(size, GraphicBufferFormat Rgba8888, GraphicBufferUsage Texture | GraphicBufferUsage RenderTarget), context)
	}
	free: override func {
		if (!this _recyclable)
			this _buffer free()
		super()
	}
}
}
