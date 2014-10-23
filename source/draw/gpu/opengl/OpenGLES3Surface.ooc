//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
use ooc-draw
use ooc-draw-gpu
import OpenGLES3/Fbo, OpenGLES3Map, TraceDrawer, OpenGLES3/Quad, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar

OpenGLES3Surface: class extends GpuSurface {
	_quad: Quad
	traceDrawer: TraceDrawer
	init: func (context: GpuContext){
		super(context)
		this _quad = Quad create()
	}
	recycle: func {
		this _context recycle(this)
	}
	dispose: func {
		this _quad dispose()
	}
	draw: func ~gpuimage (image: GpuImage, map: GpuMap, resolution: IntSize2D, offset := IntSize2D new()) {
		Fbo setViewport(offset width, offset height, resolution width, resolution height)
		this bind()
		this clear()
		map use()
		image bind(0)
		this _quad draw()
		this unbind()
		this update()
	}
	draw: func (image: Image, map: GpuMap, resolution: IntSize2D, offset := IntSize2D new()) {
		match (image) {
			case (i: GpuImage) => {
				this draw(image as GpuImage, map, resolution, offset)
			}
			case (i: RasterMonochrome) => {
				temp := OpenGLES3Monochrome create(image as RasterMonochrome, this _context)
				this draw(image as RasterMonochrome, map, resolution, offset)
				temp recycle()
			}
			case (i: RasterBgr) => {
				temp := OpenGLES3Bgr create(image as RasterBgr, this _context)
				this draw(image as RasterBgr, map, resolution, offset)
				temp recycle()
			}
			case (i: RasterBgra) => {
				temp := OpenGLES3Bgra create(image as RasterBgra, this _context)
				this draw(image as RasterBgra, map, resolution, offset)
				temp recycle()
			}
			case (i: RasterUv) => {
				temp := OpenGLES3Uv create(image as RasterUv, this _context)
				this draw(image as RasterUv, map, resolution, offset)
				temp recycle()
			}
			case (i: RasterYuv420Semiplanar) => {
				temp := OpenGLES3Yuv420Semiplanar create(image as RasterYuv420Semiplanar, this _context)
				this draw(image as RasterYuv420Semiplanar, map, resolution, offset)
				temp recycle()
			}
			case (i: RasterYuv420Planar) => {
				temp := OpenGLES3Yuv420Planar create(image as RasterYuv420Planar, this _context)
				this draw(image as RasterYuv420Planar, map, resolution, offset)
				temp recycle()
			}
			case =>
				raise("Couldnt match image type in OpenGLES3Surface")
		}
	}
	drawLines: func (transform: FloatTransform2D, screenSize: IntSize2D) {
		if (this traceDrawer == null)
			this traceDrawer = TraceDrawer new(screenSize)
		this bind()
		this traceDrawer add(transform)
		this traceDrawer draw()
		this unbind()
		this update()
	}
	clear: func
	bind: func
	unbind: func
	update: func
	create: static func (context: GpuContext)-> This {
		result := context getSurface() as This
		if(result == null)
			result = This new(context)
		result
	}
}
