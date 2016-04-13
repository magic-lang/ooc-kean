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
		gpuMap: Map = drawState map as Map ?? (drawState mesh ? this context meshShader as Map : this context defaultMap as Map)
		viewport := drawState getViewport()
		this context backend setViewport(viewport)
		focalLengthPerWidth := drawState getFocalLengthNormalized()
		targetSize := this size toFloatVector2D()
		gpuMap view = this _createView(targetSize, drawState getTransformNormalized())
		gpuMap projection = this _createProjection(targetSize, focalLengthPerWidth)
		gpuMap model = this _createModelTransformNormalized(this size, drawState getDestinationNormalized(), focalLengthPerWidth * this size x)
		gpuMap textureTransform = This _createTextureTransform(drawState getSourceNormalized())
		if (drawState opacity < 1.0f)
			this context backend blend(drawState opacity)
		else if (drawState blendMode == BlendMode Add)
			this context backend blend()
		else
			this context backend enableBlend(false)
		tempImageA: GpuImage = null
		tempImageB: GpuImage = null
		if (drawState inputImage) {
			match (drawState inputImage) {
				case (image: RasterYuv420Semiplanar) =>
					tempImageA = this _context createImage(image y)
					tempImageB = this _context createImage(image uv)
					gpuMap add("texture0", tempImageA)
					gpuMap add("texture1", tempImageB)
				case (image: RasterImage) =>
					tempImageA = this _context createImage(image)
					gpuMap add("texture0", tempImageA)
				case (image: GpuYuv420Semiplanar) =>
					gpuMap add("texture0", image y)
					gpuMap add("texture1", image uv)
				case (image: GpuImage) =>
					gpuMap add("texture0", image)
			}
		}
		gpuMap use(this _target)
		this _bind()
		if (drawState mesh)
			drawState mesh draw()
		else
			this context drawQuad()
		this _unbind()
		if (tempImageA)
			tempImageA free()
		if (tempImageB)
			tempImageB free()
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
	fill: override func (color: ColorRgba) {
		this _bind()
		this _renderTarget setClearColor(color)
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: func (buffer: ByteBuffer) { this _renderTarget readPixels(buffer) }
}
}
