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
	init: func {
	}
	draw: func ~gpuimage (image: GpuImage, map: GpuMap, resolution: IntSize2D) {
		this bind()
		this clear()
		map use()
		image bind(0)
		this _quad draw()
		this unbind()
		this update()
	}
	draw: func (image: Image, map: GpuMap, resolution: IntSize2D) {
		match (image) {
			case (i: GpuImage) => {
				this draw(image as GpuImage, map, resolution)
			}
			case (i: RasterMonochrome) => {
				temp := OpenGLES3Monochrome createStatic(image as RasterMonochrome)
				this draw(image as RasterMonochrome, map, resolution)
				temp recycle()
			}
			case (i: RasterBgr) => {
				temp := OpenGLES3Bgr createStatic(image as RasterBgr)
				this draw(image as RasterBgr, map, resolution)
				temp recycle()
			}
			case (i: RasterBgra) => {
				temp := OpenGLES3Bgra createStatic(image as RasterBgra)
				this draw(image as RasterBgra, map, resolution)
				temp recycle()
			}
			case (i: RasterUv) => {
				temp := OpenGLES3Uv createStatic(image as RasterUv)
				this draw(image as RasterUv, map, resolution)
				temp recycle()
			}
			case (i: RasterYuv420Semiplanar) => {
				temp := OpenGLES3Yuv420Semiplanar createStatic(image as RasterYuv420Semiplanar)
				this draw(image as RasterYuv420Semiplanar, map, resolution)
				temp recycle()
			}
			case (i: RasterYuv420Planar) => {
				temp := OpenGLES3Yuv420Planar createStatic(image as RasterYuv420Planar)
				this draw(image as RasterYuv420Planar, map, resolution)
				temp recycle()
			}
			case =>
				raise("Couldnt match image type in OpenGLES3Surface")
		}
	}
	drawLines: func (transform: FloatTransform2D, screenSize: IntSize2D) {
		if(this traceDrawer == null)
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
	create: static func -> This {
		result := This new()
		result _quad = Quad create()
		result
	}
}
