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
OpenGLWindow: class {
	_context: GpuContext
	context ::= this _context as OpenGLContext
	init: func (display: Pointer, nativeBackend: Long) {
		context := OpenGLContext new(display, nativeBackend)
		this _context = context
	}
	free: override func {
		this _context free()
		super()
	}
	_getDefaultMap: func (image: Image) -> Map {
		match (image class) {
			case GpuYuv420Semiplanar => this context _yuvSemiplanarToRgba
			case RasterYuv420Semiplanar => this context _yuvSemiplanarToRgba
			case OpenGLMonochrome => this context _monochromeToRgba
			case RasterMonochrome => this context _monochromeToRgba
			case => this context defaultMap
		}
	}
	refresh: func { this context update() }
}
}
