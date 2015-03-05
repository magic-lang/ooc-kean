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

import OpenGLES3/Fbo, OpenGLES3/Quad, OpenGLES3/Texture, OpenGLES3Bgr, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, Map/OpenGLES3Map, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Monochrome, OpenGLES3Surface
import structs/LinkedList

OpenGLES3Canvas: class extends GpuCanvas {
	_renderTarget: Fbo
	clearColor := 0.0f
	init: func (image: GpuImage, context: GpuContext) {
		super(image, context)
	}
	free: override func {
		this _renderTarget free()
		super()
	}
	onRecycle: func {
		this _renderTarget invalidate()
	}
	draw: func (image: Image) {
		map := this _context getMap(this _target)
		viewport := Viewport new(this _size)
		this draw(image, map, viewport)
	}
	// Postcondition: Returns the transform to apply directly to a quad for rendering with compensation for aspect ratio.
	getFinalTransform: static func (imageSize: IntSize2D, transform: FloatTransform2D) -> FloatTransform2D {
		toReference := FloatTransform2D createScaling(imageSize width / 2.0f, imageSize height / 2.0f)
		toNormalized := FloatTransform2D createScaling(2.0f / imageSize width, 2.0f / imageSize height)
		toNormalized * transform * toReference
	}
	draw: func ~transform2D (image: Image, transform: FloatTransform2D) {
		map := this _context getMap(this _target, GpuMapType transform) as OpenGLES3MapDefault
		map transform = getFinalTransform(this _size, transform)
		viewport := Viewport new(this _size)
		this draw(image, map, viewport)
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport) {
		this _bind()
		Fbo setClearColor(this clearColor)
		Fbo enableBlend(this blend)
		surface := this _context createSurface()
		surface draw(image, map, viewport)
		surface recycle()
		Fbo enableBlend(false)
		Fbo setClearColor(0.0f)
		this _unbind()
	}
	draw: func ~withmapTwoImages (image1: Image, image2: Image, map: GpuMap, viewport: Viewport) {
		this _bind()
		Fbo setClearColor(this clearColor)
		Fbo enableBlend(this blend)
		surface := this _context createSurface()
		surface draw(image1, image2, map, viewport)
		surface recycle()
		Fbo enableBlend(false)
		Fbo setClearColor(0.0f)
		this _unbind()
	}
	drawSurface: func (function: Func (OpenGLES3Surface, FloatTransform2D)) {
		this _bind()
		this _setViewport()
		transform := FloatTransform2D createScaling(2.0f / this _size width, 2.0f / this _size height)
		surface := this _context createSurface() as OpenGLES3Surface
		function(surface, transform)
		surface recycle()
		this _unbind()
	}
	// TODO: Clean these 3 functions up...
	drawLines: override func (pointList: VectorList<FloatPoint2D>) {
		drawLinesFunc := func (surface: OpenGLES3Surface, transform: FloatTransform2D) { surface drawLines(pointList, transform) }
		this drawSurface(drawLinesFunc)
		(drawLinesFunc as Closure) dispose()
	}
	drawBox: override func (box: FloatBox2D) {
		drawBoxFunc := func (surface: OpenGLES3Surface, transform: FloatTransform2D) { surface drawBox(box, transform) }
		this drawSurface(drawBoxFunc)
		(drawBoxFunc as Closure) dispose()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) {
		drawPointsFunc := func (surface: OpenGLES3Surface, transform: FloatTransform2D) { surface drawPoints(pointList, transform) }
		this drawSurface(drawPointsFunc)
		(drawPointsFunc as Closure) dispose()
	}
	_setViewport: func {
		viewport := Viewport new(this _size)
		Fbo setViewport(viewport offset width, viewport offset height, viewport resolution width, viewport resolution height)
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
	readPixels: override func () -> ByteBuffer {
		this _renderTarget readPixels()
	}
	create: static func (image: GpuPacked, context: GpuContext) -> This {
		result := This new(image, context)
		result _renderTarget = Fbo create(image texture _backend as Texture, image size width, image size height)
		result _size = image size
		result _renderTarget != null ? result : null
	}
}
OpenGLES3CanvasYuv420Planar: class extends GpuCanvas {
	target ::= this _target as GpuYuv420Planar

	init: func (image: GpuImage, context: GpuContext) { super(image, context) }
	onRecycle: func
	_draw: func (image: OpenGLES3Yuv420Planar) {
		this target y canvas draw(image y)
		this target u canvas draw(image u)
		this target v canvas draw(image v)
	}
	_draw: func ~transform2D (image: OpenGLES3Yuv420Planar, transform: FloatTransform2D) {
		this target y canvas draw(image y, transform)
		this target u canvas draw(image u, transform)
		this target v canvas draw(image v, transform)
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
	draw: func ~withmapTwoImages (image1: Image, image2: Image, map: GpuMap, viewport: Viewport)
	clear: func {
		this target y canvas clear()
		this target u canvas clear()
		this target v canvas clear()
	}
	_bind: func
	create: static func (image: OpenGLES3Yuv420Planar, context: GpuContext) -> This { This new(image, context) }
}

OpenGLES3CanvasYuv420Semiplanar: class extends GpuCanvas {
	target ::= this _target as GpuYuv420Semiplanar

	init: func (image: GpuImage, context: GpuContext) { super(image, context) }
	onRecycle: func
	_draw: func (image: OpenGLES3Yuv420Semiplanar) {
		this target y canvas draw(image y)
		this target uv canvas draw(image uv)
	}
	_draw: func ~transform2D (image: OpenGLES3Yuv420Semiplanar, transform: FloatTransform2D) {
		this target y canvas draw(image y, transform)
		uvTransform := FloatTransform2D new(transform a, transform b, transform c * 2.0f, transform d, transform e, transform f * 2.0f, transform g / 2.0f, transform h / 2.0f, transform i)
		this target uv canvas draw(image uv, uvTransform)
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
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Semiplanar")
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
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Semiplanar")
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	draw: func ~withmapTwoImages (image1: Image, image2: Image, map: GpuMap, viewport: Viewport)
	clear: func {
		this target y canvas clear()
		this target uv canvas clear()
	}
	_bind: func
	create: static func (image: OpenGLES3Yuv420Semiplanar, context: GpuContext) -> This { This new(image, context) }
}
