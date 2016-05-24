/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use geometry
use draw
use draw-gpu
import backend/GLTexture
import OpenGLPacked, OpenGLContext

version(!gpuOff) {
OpenGLRgb: class extends OpenGLPacked {
	init: func (size: IntVector2D, stride: UInt, data: Pointer, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Rgb, size, stride, data, true), This channelCount, context)
	}
	init: func ~empty (size: IntVector2D, context: OpenGLContext) {
		this init(size, size x * This channelCount, null, context)
	}
	init: func ~fromRaster (rasterImage: RasterRgb, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
	}
	toRasterDefault: override func -> RasterImage { Debug error("toRasterDefault not implemented for RGB"); null }
	toRasterDefault: override func ~target (target: RasterImage) { Debug error("toRasterDefault~target not implemented for RGB") }
	create: override func (size: IntVector2D) -> This { this context createRgb(size) as This }
	channelCount: static Int = 3
}
}
