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
import backend/GLTexture
import OpenGLCanvas, OpenGLPacked, OpenGLContext, OpenGLMap

version(!gpuOff) {
OpenGLUv: class extends OpenGLPacked {
	init: func ~fromPixels (size: IntVector2D, stride: UInt, data: Pointer, coordinateSystem: CoordinateSystem, context: OpenGLContext) {
		super(context _backend createTexture(TextureType Uv, size, stride, data), This channelCount, context)
		this _coordinateSystem = coordinateSystem
	}
	init: func (size: IntVector2D, context: OpenGLContext) {
		this init(size, size x * This channelCount, null, CoordinateSystem YUpward, context)
	}
	init: func ~fromTexture (texture: GLTexture, context: OpenGLContext) { super(texture, This channelCount, context) }
	init: func ~fromRaster (rasterImage: RasterUv, context: OpenGLContext) {
		this init(rasterImage size, rasterImage stride, rasterImage buffer pointer, rasterImage coordinateSystem, context)
	}
	toRasterDefault: override func -> RasterImage {
		result := RasterUv new(this size)
		this toRasterDefault(result)
		result
	}
	toRasterDefault: override func ~target (target: RasterImage) {
		packed := this context createRgba(IntVector2D new(this size x / 2, this size y))
		this context packToRgba(this, packed, IntBox2D new(packed size))
		buffer := (target as RasterUv) buffer
		(packed canvas as OpenGLCanvas) readPixels(buffer)
		packed free()
	}
	_createCanvas: override func -> GpuCanvas {
		result := super()
		result pen = Pen new(ColorRgba new(128, 128, 128, 128))
		result
	}
	create: override func (size: IntVector2D) -> This { this context createUv(size) as This }
	channelCount: static Int = 2
}
}
