/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-math
use ooc-base
use ooc-collections
use ooc-draw
use ooc-draw-gpu

import OpenGLES3/Fbo, OpenGLES3/Quad, OpenGLES3/Texture, OpenGLES3Bgr, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3Map, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Monochrome, OpenGLES3Surface
import structs/LinkedList

OpenGLES3Canvas: class extends GpuCanvas {
	_renderTarget: Fbo
	clearColor := 0.0f
	init: func (image: GpuImage, context: GpuContext) {
		super(image, context)
	}
	dispose: func {
		this _renderTarget dispose()
	}
	onRecycle: func {
		this _renderTarget invalidate()
	}
	draw: func (image: Image) {
		map := this _context getMap(this _target)
		viewport := Viewport new(this _size)
		this draw(image, map, viewport)
	}
	draw: func ~transform2D (image: Image, transform: FloatTransform2D) {
		map := this _context getMap(this _target, GpuMapType transform) as OpenGLES3MapTransform
		map transform = transform
		map imageSize = image size
		viewport := Viewport new(this _size)
		this draw(image, map, viewport)
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport) {
		this _bind()
		Fbo clearColor(this clearColor)
		surface := this _context createSurface()
		surface draw(image, map, viewport)
		surface recycle()
		Fbo clearColor(0.0f)
		this _unbind()
	}
	drawLogo: func (image: Image, map: GpuMap, size: IntSize2D, offset: IntSize2D, transform := FloatTransform2D identity) {
		this _bind()
		this _renderTarget clearColor(this clearColor)
		surface := this _context createSurface() as OpenGLES3Surface
		viewport := Viewport new(size)
		viewport offset = offset
		surface setBlendFactor(true)
		surface draw(image, map, viewport)
		surface setBlendFactor(false)
		surface recycle()
		this _renderTarget clearColor(0.0f)
		this _unbind()
	}
	drawTrace: func (transformList: LinkedList<FloatPoint2D>, size: IntSize2D, positions: Float*, screenSize: IntSize2D) {
		this _bind()
		surface := this _context createSurface() as OpenGLES3Surface
		surface drawTrace(transformList, Viewport new(size), positions, screenSize)
		surface recycle()
		this _unbind()
	}
	drawBox: func (box: IntBox2D, size: IntSize2D) {
		this _bind()
		surface := this _context createSurface() as OpenGLES3Surface
		surface drawBox(box, Viewport new(size), size)
		surface recycle()
		this _unbind()
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, size: IntSize2D) {
		this _bind()
		surface := this _context createSurface() as OpenGLES3Surface
		surface drawPoints(pointList, Viewport new(size), size)
		surface recycle()
		this _unbind()
	}
	_bind: func {
		this _renderTarget bind()
	}
	_unbind: func {
		this _renderTarget unbind()
	}
	clear: func {
		this _bind()
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: func (channels: UInt) -> ByteBuffer {
		this _renderTarget readPixels(channels)
	}
	create: static func (image: GpuImage, context: GpuContext) -> This {
		result := This new(image, context)
		result _renderTarget = Fbo create(image _backend as Texture, image size width, image size height)
		result _size = image size
		result _renderTarget != null ? result : null
	}
}
OpenGLES3CanvasYuv420Planar: class extends GpuCanvas {
	_y: OpenGLES3Canvas
	_u: OpenGLES3Canvas
	_v: OpenGLES3Canvas

	init: func (image: GpuImage, context: GpuContext) {
		super(image, context)
	}
	dispose: func {
		this _y dispose()
		this _u dispose()
		this _v dispose()
	}
	onRecycle: func {
		this _y onRecycle()
		this _u onRecycle()
		this _v onRecycle()
	}
	_draw: func (image: OpenGLES3Yuv420Planar) {
		this _y draw(image y)
		this _u draw(image u)
		this _v draw(image v)
	}
	_draw: func ~transform2D (image: OpenGLES3Yuv420Planar, transform: FloatTransform2D) {
		this _y draw(image y, transform)
		this _u draw(image u, transform)
		this _v draw(image v, transform)
	}
	draw: func (image: Image) {
		if (image instanceOf?(RasterYuv420Planar)) {
			temp := this _context createGpuImage(image as RasterYuv420Planar) as OpenGLES3Yuv420Planar
			this _draw(temp)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Planar)) {
			temp := image as OpenGLES3Yuv420Planar
			this _draw(temp)
		}
		else
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Planar")
	}
	draw: func ~transform2D (image: Image, transform: FloatTransform2D) {
		if (image instanceOf?(RasterYuv420Planar)) {
			temp := this _context createGpuImage(image as RasterYuv420Planar) as OpenGLES3Yuv420Planar
			this _draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Planar)) {
			temp := image as OpenGLES3Yuv420Planar
			this _draw(temp, transform)
		}
		else
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Planar")
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	{

	}
	clear: func {
		this _y clear()
		this _u clear()
		this _v clear()
	}
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Planar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage, this _context)
		this _u = OpenGLES3Canvas create(image u as GpuImage, this _context)
		this _v = OpenGLES3Canvas create(image v as GpuImage, this _context)
		this _y != null && this _u != null && this _v != null
	}
	create: static func (image: OpenGLES3Yuv420Planar, context: GpuContext) -> This {
		result := This new(image, context)
		result _generate(image) ? result : null
		result
	}
}

OpenGLES3CanvasYuv420Semiplanar: class extends OpenGLES3Canvas {
	_y: OpenGLES3Canvas
	_uv: OpenGLES3Canvas

	init: func (image: GpuImage, context: GpuContext) {
		super(image, context)
	}
	dispose: func {
		this _y dispose()
		this _uv dispose()
	}
	onRecycle: func {
		this _y onRecycle()
		this _uv onRecycle()
	}
	_draw: func (image: OpenGLES3Yuv420Semiplanar) {
		this _y draw(image y)
		this _uv draw(image uv)
	}
	_draw: func ~transform2D (image: OpenGLES3Yuv420Semiplanar, transform: FloatTransform2D) {
		this _y draw(image y, transform)
		//uvTransform := transform translate(-transform g / 2.0f, -transform h / 2.0f)
		uvTransform := FloatTransform2D new(transform a, transform b, transform c * 2.0f, transform d, transform e, transform f * 2.0f, transform g / 2.0f, transform h / 2.0f, transform i)
		this _uv draw(image uv, uvTransform)
	}
	draw: func (image: Image) {
		if (image instanceOf?(RasterYuv420Semiplanar)) {
			temp := this _context createGpuImage(image as RasterYuv420Semiplanar) as OpenGLES3Yuv420Semiplanar
			this _draw(temp)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Semiplanar)) {
			temp := image as OpenGLES3Yuv420Semiplanar
			this _draw(temp)
		}
		else
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Planar")
	}
	draw: func ~transform2D (image: Image, transform: FloatTransform2D) {
		if (image instanceOf?(RasterYuv420Semiplanar)) {
			temp := this _context createGpuImage(image as RasterYuv420Semiplanar) as OpenGLES3Yuv420Semiplanar
			this _draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Semiplanar)) {
			temp := image as OpenGLES3Yuv420Semiplanar
			this _draw(temp, transform)
		}
		else
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Planar")
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	{

	}
	clear: func {
		this _y clear()
		this _uv clear()
	}
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Semiplanar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage, this _context)
		this _uv = OpenGLES3Canvas create(image uv as GpuImage, this _context)
		this _y != null && this _uv != null
	}
	create: static func (image: OpenGLES3Yuv420Semiplanar, context: GpuContext) -> This {
		result := This new(image, context)
		result _generate(image) ? result : null
		result
	}
}
