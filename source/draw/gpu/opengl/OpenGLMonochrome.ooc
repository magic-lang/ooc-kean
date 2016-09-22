/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use draw-gpu
use base
import OpenGLPacked, OpenGLMap, OpenGLContext
import backend/GLTexture

version(!gpuOff) {
OpenGLMonochrome: class extends OpenGLPacked {
	init: func ~fromPixels (size: IntVector2D, stride: UInt, data: Pointer, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Monochrome, size, stride, data), This channelCount, context)
	}
	init: func (size: IntVector2D, context: OpenGLContext) { this init(size, size x, null, context) }
	init: func ~fromTexture (texture: GLTexture, context: OpenGLContext) { super(texture, This channelCount, context) }
	init: func ~fromRaster (rasterImage: RasterMonochrome, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, context)
	}
	toRasterDefault: override func -> RasterImage {
		result := RasterMonochrome new(this size)
		this toRasterDefault(result)
		result
	}
	toRasterDefault: override func ~target (target: RasterImage) {
		packed := this context createRgba(IntVector2D new(this size x / 4, this size y))
		this context packToRgba(this, packed, IntBox2D new(packed size))
		(packed as OpenGLPacked) readPixels(target as RasterPacked) . free()
	}
	create: override func (size: IntVector2D) -> This { this context createMonochrome(size) as This }
	channelCount: static Int = 1
}
}
