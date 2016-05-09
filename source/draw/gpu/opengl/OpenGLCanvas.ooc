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
import OpenGLMap, OpenGLRgb, OpenGLRgba, OpenGLUv, OpenGLMonochrome, OpenGLContext, OpenGLPacked

version(!gpuOff) {
OpenGLCanvas: class extends GpuCanvas {
	_target: OpenGLPacked
	_renderTarget: GLFramebufferObject
	_toLocal := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
	context ::= this _context as OpenGLContext
	draw: override func ~DrawState (drawState: DrawState) {
		gpuMap: Map = drawState map as Map ?? this context defaultMap as Map
		viewport := drawState getViewport()
		this context backend setViewport(viewport)
		focalLengthPerWidth := drawState getFocalLengthNormalized()
		targetSize := this size toFloatVector2D()
		model := (drawState mesh) ? FloatTransform3D identity : this _createModelTransformNormalized(this size, drawState getDestinationNormalized(), focalLengthPerWidth * this size x)
		view := (drawState mesh) ? FloatTransform3D identity : this _createView(targetSize, drawState getTransformNormalized())
		projection := this _createProjection(targetSize, focalLengthPerWidth)
		textureTransform := This _createTextureTransform(drawState getSourceNormalized(), drawState flipSourceX, drawState flipSourceY)
		if (drawState opacity < 1.0f)
			this context backend blend(drawState opacity)
		else if (drawState blendMode == BlendMode Add)
			this context backend blend()
		else
			this context backend disableBlend()
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
		gpuMap use(this _target, projection * view * model, textureTransform)
		this _renderTarget bind()
		if (drawState mesh)
			drawState mesh draw()
		else
			this context drawQuad()
		this _renderTarget unbind()
		if (tempImageA)
			tempImageA free()
		if (tempImageB)
			tempImageB free()
	}
	init: func (=_target, context: OpenGLContext) {
		super(this _target size, context, context defaultMap)
		this _renderTarget = context _backend createFramebufferObject(this _target _backend as GLTexture, this _target size)
	}
	free: override func {
		this _renderTarget free()
		super()
	}
	_createTextureTransform: static func (normalizedBox: FloatBox2D, flipX, flipY: Bool) -> FloatTransform3D {
		flipScaleX := flipX ? -1.0f : 1.0f
		flipScaleY := flipY ? -1.0f : 1.0f
		scaling := FloatTransform3D createScaling(normalizedBox size x * flipScaleX, normalizedBox size y * flipScaleY, 1.0f)
		translation := FloatTransform3D createTranslation((normalizedBox leftTop x * flipScaleX) + (flipX ? 1.0f : 0.0f), (normalizedBox leftTop y * flipScaleY) + (flipY ? 1.0f : 0.0f), 0.0f)
		translation * scaling
	}
	drawLines: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		this _renderTarget bind()
		this context backend setViewport(IntBox2D new(this size))
		this context backend disableBlend()
		this context drawLines(pointList, this _createProjection(this size toFloatVector2D(), 0.0f) * this _toLocal, pen)
		this _renderTarget unbind()
	}
	drawPoints: override func ~explicit (pointList: VectorList<FloatPoint2D>, pen: Pen) {
		this _renderTarget bind()
		this context backend setViewport(IntBox2D new(this size))
		this context backend disableBlend()
		this context drawPoints(pointList, this _createProjection(this size toFloatVector2D(), 0.0f) * this _toLocal, pen)
		this _renderTarget unbind()
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
		flipX := 1.0f
		flipY := -1.0f
		if (focalLengthPerWidth > 0.0f) {
			nearPlane := 0.01f
			farPlane := 12500.0f
			a := flipX * 2.0f * focalLengthPerWidth
			f := flipY * 2.0f * focalLengthPerHeight
			k := (farPlane + nearPlane) / (farPlane - nearPlane)
			o := 2.0f * farPlane * nearPlane / (farPlane - nearPlane)
			result = FloatTransform3D new(a, 0.0f, 0.0f, 0.0f, 0.0f, f, 0.0f, 0.0f, 0.0f, 0.0f, k, -1.0f, 0.0f, 0.0f, o, 0.0f)
		} else
			result = FloatTransform3D createScaling(flipX * 2.0f / targetSize x, flipY * 2.0f / targetSize y, 0.0f)
		result
	}
	onRecycle: func { this _renderTarget invalidate() }
	fill: override func (color: ColorRgba) {
		this _renderTarget bind()
		this _renderTarget setClearColor(color)
		this _renderTarget clear()
		this _renderTarget unbind()
	}
	readPixels: func (buffer: ByteBuffer) { this _renderTarget readPixels(buffer) }
}
}
