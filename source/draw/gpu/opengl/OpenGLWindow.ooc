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
OpenGLWindow: class extends GpuCanvas {
	_toLocal := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
	context ::= this _context as OpenGLContext
	drawLines: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) { raise("Cannot draw lines directly to a window.") }
	drawPoints: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) { raise("Cannot draw lines directly to a window.") }
	_createModelTransform: func ~LocalFloat (box: FloatBox2D, focalLength: Float) -> FloatTransform3D {
		toReference := FloatTransform3D createTranslation((box size x - this size x) / 2, (this size y - box size y) / 2, 0.0f)
		translation := this _toLocal * FloatTransform3D createTranslation(box leftTop x, box leftTop y, focalLength) * this _toLocal
		translation * toReference * FloatTransform3D createScaling(box size x / 2.0f, box size y / 2.0f, 1.0f)
	}
	_createView: func (targetSize: FloatVector2D, normalizedView: FloatTransform3D) -> FloatTransform3D {
		this _toLocal * normalizedView normalizedToReference(targetSize) * this _toLocal
	}
	_createProjection: func (targetSize: FloatVector2D, focalLengthPerWidth: Float) -> FloatTransform3D {
		flipX := this _coordinateTransform a as Float
		flipY := -(this _coordinateTransform e as Float)
		FloatTransform3D createScaling(flipX * 2.0f / targetSize x, flipY * 2.0f / targetSize y, 0.0f)
	}
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
	_bind: virtual func
	_unbind: virtual func
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
