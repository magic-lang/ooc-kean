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
	_quad: Quad

	init: func (map: OpenGLES3MapDefault) {
		super()
		this _map = map
		this _surface = OpenGLES3Surface new()
	}
	dispose: func {
		this _renderTarget dispose()
	}
	setResolution: func (resolution: IntSize2D) {
		Fbo setViewport(0, 0, resolution width, resolution height)
	}
	draw: func (image: Image, transform: FloatTransform2D) {
		this _map transform = transform
		this _map imageSize = image size
		this _map screenSize = image size
		clearColor := 0.0f

		if(image instanceOf?(OpenGLES3Uv)) {
			this _map transform  = transform setTranslation(FloatSize2D new (transform g / 2.0f, transform h / 2.0f))
			clearColor = 0.5f
		}
		this _renderTarget clearColor(clearColor)
		this _surface draw(image, this _map, this _size)
		this _renderTarget clearColor(0.0f)
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
	create: static func (image: GpuImage) -> This {
		map := match(image) {
			case (i : OpenGLES3Bgr) => OpenGLES3MapBgr new()
			case (i : OpenGLES3Bgra) => OpenGLES3MapBgra new()
			case (i : OpenGLES3Monochrome) => OpenGLES3MapMonochrome new()
			case (i : OpenGLES3Uv) => OpenGLES3MapUv new()
		}
		result := This new(map)
		result _renderTarget = Fbo create(image _backend as Texture, image size width, image size height)
		result _quad = Quad create()
		result _size = image size
		result _renderTarget != null ? result : null
	}
}


OpenGLES3CanvasYuv420Planar: class extends GpuCanvas {
	_y: OpenGLES3Canvas
	_u: OpenGLES3Canvas
	_v: OpenGLES3Canvas

	init: func
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
	draw: func ~noTransform (image: Image) {
		this draw(image, FloatTransform2D identity)
	}
	draw: func (image: Image, transform: FloatTransform2D) {
		if (image instanceOf?(RasterYuv420Planar)) {
			temp := OpenGLES3Yuv420Planar createStatic(image as RasterYuv420Planar)
			this draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Planar))
			this draw(image as OpenGLES3Yuv420Planar, transform)
	}
	_clear: func
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Planar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage)
		this _u = OpenGLES3Canvas create(image u as GpuImage)
		this _v = OpenGLES3Canvas create(image v as GpuImage)
		this _y != null && this _u != null && this _v != null
	}
	create: static func (image: OpenGLES3Yuv420Planar) -> This {
		result := This new()
		result _generate(image) ? result : null
		result
	}
}

OpenGLES3CanvasYuv420Semiplanar: class extends OpenGLES3Canvas {
	_y: OpenGLES3Canvas
	_uv: OpenGLES3Canvas

	init: func
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
	draw: func (image: Image, transform: FloatTransform2D) {
		if (image instanceOf?(RasterYuv420Semiplanar)) {
			temp := OpenGLES3Yuv420Semiplanar createStatic(image as RasterYuv420Semiplanar)
			this draw(temp, transform)
			temp recycle()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Semiplanar))
			this draw(image as OpenGLES3Yuv420Semiplanar, transform)
	}
	_clear: func
	_bind: func
	_generate: func (image: OpenGLES3Yuv420Semiplanar) -> Bool {
		this _y = OpenGLES3Canvas create(image y as GpuImage)
		this _uv = OpenGLES3Canvas create(image uv as GpuImage)
		this _y != null && this _uv != null
	}
	create: static func (image: OpenGLES3Yuv420Semiplanar) -> This {
		result := This new()
		result _generate(image) ? result : null
		result
	}
}
