/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
use collections
use draw
use draw-gpu
import backend/[GLFramebufferObject, GLTexture]
import OpenGLMap, OpenGLRgb, OpenGLRgba, OpenGLUv, OpenGLMonochrome, OpenGLContext, OpenGLPacked, OpenGLSurface

version(!gpuOff) {
OpenGLCanvas: class extends OpenGLSurface {
	_target: OpenGLPacked
	_renderTarget: GLFramebufferObject
	context ::= this _context as OpenGLContext
	draw: override func ~DrawState (drawState: DrawState) {
		gpuMap: Map = drawState map as Map ?? this context defaultMap
		viewport := (drawState viewport hasZeroArea) ? IntBox2D new(this size) : drawState viewport
		this context backend setViewport(viewport)
		gpuMap view = _toLocal * drawState getTransformNormalized() normalizedToReference(this size) * _toLocal
		if (this _focalLength > 0.0f) {
			a := 2.0f * this _focalLength / this size x
			f := -(this _coordinateTransform e as Float) * 2.0f * this _focalLength / this size y
			k := (this _farPlane + this _nearPlane) / (this _farPlane - this _nearPlane)
			o := 2.0f * this _farPlane * this _nearPlane / (this _farPlane - this _nearPlane)
			gpuMap projection = FloatTransform3D new(a, 0.0f, 0.0f, 0.0f, 0.0f, f, 0.0f, 0.0f, 0.0f, 0.0f, k, -1.0f, 0.0f, 0.0f, o, 0.0f)
		} else
			gpuMap projection = FloatTransform3D createScaling(2.0f / this size x, -(this _coordinateTransform e as Float) * 2.0f / this size y, 1.0f)
		gpuMap model = this _createModelTransformNormalized(this size, drawState getDestinationNormalized())
		gpuMap textureTransform = This _createTextureTransform(drawState getSourceNormalized())
		if (drawState opacity < 1.0f)
			this context backend blend(drawState opacity)
		else
			this context backend enableBlend(false)
		if (drawState inputImage)
			gpuMap add("texture0", drawState inputImage)
		gpuMap use()
		this _bind()
		this context drawQuad()
		this _unbind()
	}
	init: func (=_target, context: OpenGLContext) {
		super(this _target size, context, context defaultMap, IntTransform2D identity)
		this _renderTarget = context _backend createFramebufferObject(this _target _backend as GLTexture, this _target size)
	}
	free: override func {
		this _renderTarget free()
		super()
	}
	_bind: override func { this _renderTarget bind() }
	_unbind: override func { this _renderTarget unbind() }
	onRecycle: func { this _renderTarget invalidate() }
	fill: override func {
		this _bind()
		this _renderTarget setClearColor(this pen color)
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: func (buffer: ByteBuffer) { this _renderTarget readPixels(buffer) }
}
}
