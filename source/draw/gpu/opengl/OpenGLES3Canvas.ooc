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

import OpenGLES3/Fbo, OpenGLES3/Quad, OpenGLES3/Texture, OpenGLES3Bgr, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar, Map/OpenGLES3Map, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Monochrome, OpenGLES3Context

OpenGLES3Canvas: class extends GpuCanvas {
	_renderTarget: Fbo
	context ::= this _context as OpenGLES3Context
	init: func (image: GpuImage, context: GpuContext) { super(image, context) }
	free: override func {
		this _renderTarget free()
		super()
	}
	_bind: func { this _renderTarget bind() }
	_unbind: func { this _renderTarget unbind() }
	onRecycle: func { this _renderTarget invalidate() }
	draw: func ~viewport (viewport: IntBox2D) {
		this _bind()
		Fbo setViewport(viewport)
		if (this blend)
			Fbo enableBlend(this blend)
		this context drawQuad()
		if (this blend)
			Fbo enableBlend(false)
		this _unbind()
	}
	draw: func ~withmap (image: Image, map: GpuMap, viewport: IntBox2D) {
		if (image instanceOf?(GpuImage)) {
			temp := image as GpuImage
			temp bind(0)
			map reference = temp reference
			map projection = this _projection
			map use()
			this draw(viewport)
		}
		else if(image instanceOf?(RasterImage)) {
			temp := this _context createGpuImage(image as RasterImage)
			temp bind(0)
			map reference = temp reference
			map projection = this _projection
			map use()
			this draw(viewport)
			temp free()
		}
		else
			Debug raise("Invalid image type in OpenGLES3Canvas draw: func ~withmap")
	}
	draw: func (image: Image) {
		map := this _context getMap(this _target)
		this draw(image, map, this viewport)
	}
	draw: func ~transform2D (image: Image, transform: FloatTransform2D) {
		map := this _context getMap(this _target, GpuMapType transform) as OpenGLES3MapDefault
		map transform = transform
		this draw(image, map, this viewport)
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>) {
		this _bind()
		this context drawLines(pointList, this _projection)
		this _unbind()
	}
	drawBox: override func (box: FloatBox2D) {
		this _bind()
		this context drawBox(box, this _projection)
		this _unbind()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) {
		this _bind()
		this context drawPoints(pointList, this _projection)
		this _unbind()
	}
	clear: func {
		this _bind()
		this _renderTarget clear()
		this _unbind()
	}
	readPixels: override func -> ByteBuffer { this _renderTarget readPixels() }
	create: static func (image: GpuPacked, context: GpuContext) -> This {
		result := This new(image, context)
		result _renderTarget = Fbo create(image texture _backend as Texture, image size)
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
	draw: func ~withmap (image: Image, map: GpuMap)
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
			temp free()
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
			temp free()
		}
		else if (image instanceOf?(OpenGLES3Yuv420Semiplanar)) {
			temp := image as OpenGLES3Yuv420Semiplanar
			this _draw(temp, transform)
		}
		else
			raise("Trying to draw unsupported image format to OpenGLES3Yuv420Semiplanar")
	}
	draw: func ~withmap (image: Image, map: GpuMap)
	clear: func {
		this target y canvas clear()
		this target uv canvas clear()
	}
	_bind: func
	create: static func (image: OpenGLES3Yuv420Semiplanar, context: GpuContext) -> This { This new(image, context) }
}
