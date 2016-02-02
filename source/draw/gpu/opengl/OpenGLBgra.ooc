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
import backend/GLTexture
import OpenGLCanvas, OpenGLPacked, OpenGLContext

version(!gpuOff) {
OpenGLBgra: class extends OpenGLPacked {
	init: func ~fromPixels (size: IntVector2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Bgra, size, stride, data), This channelCount, context)
		this _coordinateSystem = coordinateSystem
	}
	init: func (size: IntVector2D, context: OpenGLContext) { this init(size, size x * This channelCount, null, CoordinateSystem YUpward, context) }
	init: func ~fromTexture (texture: GLTexture, context: OpenGLContext) { super(texture, This channelCount, context) }
	init: func ~fromRaster (rasterImage: RasterBgra, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: override func -> RasterImage {
		buffer := (this canvas as OpenGLCanvas) readPixels()
		RasterBgra new(buffer, this size)
	}
	create: override func (size: IntVector2D) -> This { this context createBgra(size) as This }
	channelCount: static Int = 4
}
}
