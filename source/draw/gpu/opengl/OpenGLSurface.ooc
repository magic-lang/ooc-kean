/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use geometry
use draw
use draw-gpu
import OpenGLContext, OpenGLPacked
import backend/GLRenderer

version(!gpuOff) {
OpenGLSurface: abstract class extends GpuCanvas {
	context ::= this _context as OpenGLContext
	init: func (size: IntVector2D, context: OpenGLContext, defaultMap: Map, coordinateTransform: IntTransform2D) {
		super(size, context, defaultMap, coordinateTransform)
	}
	_bind: abstract func
	_unbind: abstract func
	drawLines: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		this _bind()
		this context backend setViewport(IntBox2D new(this size))
		this context backend enableBlend(false)
		this context drawLines(pointList, this _createProjection(this size toFloatVector2D(), 0.0f) * this _toLocal, pen)
		this _unbind()
	}
	drawPoints: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		this _bind()
		this context backend setViewport(IntBox2D new(this size))
		this context backend enableBlend(false)
		this context drawPoints(pointList, this _createProjection(this size toFloatVector2D(), 0.0f) * this _toLocal, pen)
		this _unbind()
	}
}
}
