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
use ooc-draw
use ooc-draw-gpu

import OpenGLES3/Fbo, OpenGLES3/Quad, OpenGLES3/Texture, OpenGLES3Bgr, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, OpenGLES3Map, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Monochrome, OpenGLES3Surface


OpenGLES3Canvas: class extends GpuCanvas {
	_renderTarget: Fbo
	_defaultMap: OpenGLES3MapDefault
	clearColor := 0.0f
	init: func (map: GpuMap, context: GpuContext) {
		super(context)
		this _defaultMap = map as OpenGLES3MapDefault
	}
	dispose: func {
		this _renderTarget dispose()
	}
	draw: func (image: Image, transform := FloatTransform2D identity) {
		this _defaultMap transform = transform
		this _defaultMap imageSize = image size
		this _defaultMap screenSize = image size
		this _bind()
		this _renderTarget clearColor(this clearColor)
		surface := this _context createSurface()
		viewport := Viewport new(this _size)
		surface draw(image, this _defaultMap, viewport)
		surface recycle()
		this _renderTarget clearColor(0.0f)
		this _unbind()
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport) {
		this _bind()
		this _renderTarget clearColor(this clearColor)
		surface := this _context createSurface()
		surface draw(image, map, viewport)
		surface recycle()
		this _renderTarget clearColor(0.0f)
		this _unbind()
	}
	drawLines: func (transform: FloatTransform2D, size: IntSize2D) {
		this _bind()
		surface := this _context createSurface() as OpenGLES3Surface
		surface drawLines(transform, Viewport new(size))
		surface recycle()
		this _unbind()
	}
	_bind: func {
		this _renderTarget bind()
	}
	_unbind: func {
		this _renderTarget unbind()
	}
	_clear: func {
		this _renderTarget clear()
	}
	readPixels: func (channels: UInt) -> ByteBuffer {
		this _renderTarget readPixels(channels)
	}
	create: static func (image: GpuImage, context: GpuContext) -> This {
		map := context getDefaultMap(image)
		result := This new(map, context)
		result _renderTarget = Fbo create(image _backend as Texture, image size width, image size height)
		result _size = image size
		result _renderTarget != null ? result : null
	}
}


OpenGLES3CanvasYuv420Planar: class extends GpuCanvas {
	_y: OpenGLES3Canvas
	_u: OpenGLES3Canvas
	_v: OpenGLES3Canvas

	init: func (context: GpuContext) {
		super(context)
	}
	dispose: func {
		this _y dispose()
		this _u dispose()
		this _v dispose()
	}
	draw: func ~Yuv420Planar (image: OpenGLES3Yuv420Planar, transform := FloatTransform2D identity) {
		this _y draw(image y, transform)
		this _u draw(image u, transform)
		this _v draw(image v, transform)
	}
	draw: func (image: Image, transform := FloatTransform2D identity) {
		if (image instanceOf?(RasterYuv420Planar)) {
			temp := OpenGLES3Yuv420Planar create(image as RasterYuv420Planar, this _context)
			this draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Planar))
			this draw(image as OpenGLES3Yuv420Planar, transform)
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	{

	}
	_clear: func
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Planar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage, this _context)
		this _u = OpenGLES3Canvas create(image u as GpuImage, this _context)
		this _v = OpenGLES3Canvas create(image v as GpuImage, this _context)
		this _y != null && this _u != null && this _v != null
	}
	create: static func (image: OpenGLES3Yuv420Planar, context: GpuContext) -> This {
		result := This new(context)
		result _generate(image) ? result : null
		result
	}
}

OpenGLES3CanvasYuv420Semiplanar: class extends OpenGLES3Canvas {
	_y: OpenGLES3Canvas
	_uv: OpenGLES3Canvas

	init: func (context: GpuContext) {
		super(context)
	}
	dispose: func {
		this _y dispose()
		this _uv dispose()
	}
	draw: func ~Yuv420Semiplanar (image: OpenGLES3Yuv420Semiplanar, transform: FloatTransform2D) {
		this _y draw(image y, transform)
		scaledTransform := transform setTranslation(FloatSize2D new (transform g / 2.0f, transform h / 2.0f))
		this _uv draw(image uv, scaledTransform)
	}
	draw: func (image: Image, transform := FloatTransform2D identity) {
		if (image instanceOf?(RasterYuv420Semiplanar)) {
			temp := OpenGLES3Yuv420Semiplanar create(image as RasterYuv420Semiplanar, this _context)
			this draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Semiplanar))
			this draw(image as OpenGLES3Yuv420Semiplanar, transform)
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	{

	}
	_clear: func
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Semiplanar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage, this _context)
		this _uv = OpenGLES3Canvas create(image uv as GpuImage, this _context)
		this _y != null && this _uv != null
	}
	create: static func (image: OpenGLES3Yuv420Semiplanar, context: GpuContext) -> This {
		result := This new(context)
		result _generate(image) ? result : null
		result
	}
}
