/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use draw
use draw-gpu
import backend/GLTexture
import OpenGLContext, OpenGLCanvas

version(!gpuOff) {
OpenGLPacked: abstract class extends GpuImage {
	_filter: Bool
	_backend: GLTexture
	_channels: UInt
	_recyclable := true
	backend ::= this _backend
	channels ::= this _channels
	context ::= this _context as OpenGLContext
	recyclable ::= this _recyclable
	filter: Bool {
		get { this _filter }
		set(value) {
			this _backend setMagFilter(InterpolationType Linear)
			this _backend setMinFilter(InterpolationType Linear)
		}
	}
	init: func (=_backend, =_channels, context: OpenGLContext, coordinateSystem := CoordinateSystem Default) {
		super(this _backend size, context, coordinateSystem)
	}
	free: override func {
		if (this recyclable)
			this context recycle(this)
		else {
			this _backend free()
			super()
		}
	}
	upload: override func (image: RasterImage) {
		if (image instanceOf(RasterPacked)) {
			raster := image as RasterPacked
			this _backend upload(raster buffer pointer, raster stride)
		}
	}
	_createCanvas: override func -> GpuCanvas { OpenGLCanvas new(this, this context) }
	onRecycle: func {
		if (this _canvas != null)
			(this _canvas as OpenGLCanvas) onRecycle()
	}
}
}
