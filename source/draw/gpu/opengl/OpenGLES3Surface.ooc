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
	clear: func
	draw: func ~gpuimage (image: GpuImage, map: GpuMap, resolution: IntSize2D, offset := IntSize2D new()) {
		Fbo setViewport(offset width, offset height, resolution width, resolution height)
		map use()
		image bind(0)
		this _quad draw()
	}
	draw: func (image: Image, map: GpuMap, resolution: IntSize2D, offset := IntSize2D new()) {
		match (image) {
			case (i: GpuImage) => {
				this draw(image as GpuImage, map, resolution, offset)
			}
			case (i: RasterImage) => {
				temp := this _context createGpuImage(image as RasterImage)
				this draw(temp, map, resolution, offset)
				temp recycle()
			}
			case =>
				raise("Couldnt match image type in OpenGLES3Surface")
		}
	}
	drawLines: func (transform: FloatTransform2D, screenSize: IntSize2D, offset := IntSize2D new()) {
		if (this traceDrawer == null)
			this traceDrawer = TraceDrawer new(screenSize)
		Fbo setViewport(offset width, offset height, screenSize width, screenSize height)
		this traceDrawer add(transform)
		this traceDrawer draw()
	}
	create: static func (context: GpuContext)-> This {
		result := context getSurface() as This
		if(result == null)
			result = This new(context)
		result
	}
}
