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
import OpenGLES3Map, TraceDrawer, OpenGLES3/Quad, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar

OpenGLES3Surface: class extends GpuSurface {
	_quad: Quad
	traceDrawer: TraceDrawer
	init: func {
	}
	draw: func ~gpuimage (image: GpuImage, map: GpuMap, resolution: IntSize2D) {
		this bind()
		this setResolution(resolution)
		this clear()
		map use()
		image bind(0)
		this _quad draw()
		this unbind()
		this update()
	}
	draw: func (image: Image, map: GpuMap, resolution: IntSize2D) {
		match (image) {
			case (image instanceOf?(GpuImage)) => { this draw(image, map, resolution) }
			case (image instanceOf?(RasterMonochrome)) => {
				/*
				temp := OpenGLES3Monochrome create(image as RasterMonochrome)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
			case (image instanceOf?(RasterBgr)) => {
				/*
				temp := OpenGLES3Bgr create(image as RasterBgr)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
			case (image instanceOf?(RasterBgra)) => {
				/*
				temp := OpenGLES3Bgra create(image as RasterBgra)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
			case (image instanceOf?(RasterUv)) => {
				/*
				temp := OpenGLES3Uv create(image as RasterUv)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
			case (image instanceOf?(RasterYuv420Semiplanar)) => {
				/*
				temp := OpenGLES3Yuv420Semiplanar create(image as RasterYuv420Semiplanar)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
			case (image instanceOf?(RasterYuv420Planar)) => {
				/*
				temp := OpenGLES3420Planar create(image as RasterYuv420Planar)
				this draw(image, map, resolution)
				temp recycle()
				*/
			}
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
	setResolution: func (resolution: IntSize2D)
	unbind: func
	update: func
	create: static func -> This {
		result := This new()
		result _quad = Quad create()
		result
	}
}
