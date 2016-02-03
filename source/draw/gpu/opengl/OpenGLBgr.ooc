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
import OpenGLCanvas, OpenGLPacked, OpenGLContext

version(!gpuOff) {
OpenGLBgr: class extends OpenGLPacked {
	init: func (size: IntVector2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Bgr, size, stride, data, true), This channelCount, context)
		this _coordinateSystem = coordinateSystem
	}
	init: func ~empty (size: IntVector2D, context: OpenGLContext) {
		this init(size, size x * This channelCount, null, CoordinateSystem YUpward, context)
	}
	init: func ~fromRaster (rasterImage: RasterBgr, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: override func -> RasterImage { Debug raise("toRasterDefault not implemented for BGR"); null }
	toRasterDefault: override func ~target (target: RasterImage) { Debug raise("toRasterDefault~target not implemented for BGR"); null }
	create: override func (size: IntVector2D) -> This { this context createBgr(size) as This }
	channelCount: static Int = 3
}
}
