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
use opengl
use base

version(!gpuOff) {
OpenGLWindow: class extends OpenGLSurface {
	_monochromeToRgba: OpenGLMap
	_yuvSemiplanarToRgba: OpenGLMapTransform
	init: func (windowSize: IntVector2D, display: Pointer, nativeBackend: Long) {
		context := OpenGLContext new(display, nativeBackend)
		super(windowSize, context, OpenGLMap new(slurp("shaders/texture.frag"), context), IntTransform2D createScaling(1, -1))
		this _monochromeToRgba = OpenGLMap new(slurp("shaders/monochromeToRgba.frag"), context)
		this _yuvSemiplanarToRgba = OpenGLMapTransform new(slurp("shaders/yuvSemiplanarToRgba.frag"), context)
	}
	free: override func {
		(this _yuvSemiplanarToRgba, this _monochromeToRgba, this _defaultMap, this _context) free()
		super()
	}
	_bind: override func
	_unbind: override func
	_getDefaultMap: override func (image: Image) -> Map {
		match (image class) {
			case GpuYuv420Semiplanar => this _yuvSemiplanarToRgba
			case RasterYuv420Semiplanar => this _yuvSemiplanarToRgba
			case OpenGLMonochrome => this _monochromeToRgba
			case RasterMonochrome => this _monochromeToRgba
			case => this context defaultMap
		}
	}
	refresh: func { this context update() }
	fill: override func (color: ColorRgba)
}
}
