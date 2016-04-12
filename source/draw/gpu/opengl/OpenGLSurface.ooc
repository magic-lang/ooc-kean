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
	_toLocal := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
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
	_createModelTransform: func ~LocalFloat (box: FloatBox2D, focalLength: Float) -> FloatTransform3D {
		toReference := FloatTransform3D createTranslation((box size x - this size x) / 2, (this size y - box size y) / 2, 0.0f)
		translation := this _toLocal * FloatTransform3D createTranslation(box leftTop x, box leftTop y, focalLength) * this _toLocal
		translation * toReference * FloatTransform3D createScaling(box size x / 2.0f, box size y / 2.0f, 1.0f)
	}
	_createModelTransformNormalized: func (imageSize: IntVector2D, box: FloatBox2D, focalLength: Float) -> FloatTransform3D {
		this _createModelTransform(box * imageSize toFloatVector2D(), focalLength)
	}
	_createView: func (targetSize: FloatVector2D, normalizedView: FloatTransform3D) -> FloatTransform3D {
		this _toLocal * normalizedView normalizedToReference(targetSize) * this _toLocal
	}
	_createProjection: func (targetSize: FloatVector2D, focalLengthPerWidth: Float) -> FloatTransform3D {
		result: FloatTransform3D
		focalLengthPerHeight := focalLengthPerWidth * targetSize x / targetSize y
		flipX := this _coordinateTransform a as Float
		flipY := -(this _coordinateTransform e as Float)
		if (focalLengthPerWidth > 0.0f) {
			nearPlane := 0.01f
			farPlane := 10000.0f
			a := flipX * 2.0f * focalLengthPerWidth
			f := flipY * 2.0f * focalLengthPerHeight
			k := (farPlane + nearPlane) / (farPlane - nearPlane)
			o := 2.0f * farPlane * nearPlane / (farPlane - nearPlane)
			result = FloatTransform3D new(a, 0.0f, 0.0f, 0.0f, 0.0f, f, 0.0f, 0.0f, 0.0f, 0.0f, k, -1.0f, 0.0f, 0.0f, o, 0.0f)
		} else
			result = FloatTransform3D createScaling(flipX * 2.0f / targetSize x, flipY * 2.0f / targetSize y, 0.0f)
		result
	}
}
}
