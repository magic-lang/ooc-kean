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
	_map: OpenGLES3MapDefault

	init: func (map: OpenGLES3MapDefault, context: GpuContext) {
		super(context)
		this _map = map
	}
	dispose: func {
		this _renderTarget dispose()
	}
	draw: func (image: Image, transform := FloatTransform2D identity) {
		this _map transform = transform
		this _map imageSize = image size
		this _map screenSize = image size
		clearColor := 0.0f
		if (image instanceOf?(OpenGLES3Uv)) {
			this _map transform  = transform setTranslation(FloatSize2D new (transform g / 2.0f, transform h / 2.0f))
			clearColor = 0.5f
		}
		this _bind()
		this _renderTarget clearColor(clearColor)
		surface := OpenGLES3Surface create(this _context)
		surface draw(image, this _map, this _size)
		surface recycle()
		this _renderTarget clearColor(0.0f)
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
		map := match(image) {
			case (i : OpenGLES3Bgr) => OpenGLES3MapBgr new()
			case (i : OpenGLES3Bgra) => OpenGLES3MapBgra new()
			case (i : OpenGLES3Monochrome) => OpenGLES3MapMonochrome new()
			case (i : OpenGLES3Uv) => OpenGLES3MapUv new()
		}
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
	draw: func ~noTransform (image: Image) {
		this draw(image, FloatTransform2D identity)
	}
	draw: func ~Yuv420Semiplanar (image: OpenGLES3Yuv420Semiplanar, transform: FloatTransform2D) {
		this _y draw(image y, transform)
		//this _y drawLines(transform, image size)
		this _uv draw(image uv, transform)
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
