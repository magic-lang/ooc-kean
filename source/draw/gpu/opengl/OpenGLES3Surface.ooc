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
use ooc-collections
use ooc-draw
use ooc-draw-gpu
import OpenGLES3/Fbo, Map/OpenGLES3Map, OverlayDrawer, OpenGLES3/Quad, OpenGLES3Monochrome, OpenGLES3Bgr, OpenGLES3Bgra, OpenGLES3Uv, OpenGLES3Yuv420Semiplanar, OpenGLES3Yuv420Planar
import structs/LinkedList

OpenGLES3Surface: class extends GpuSurface {
	_quad: Quad
	overlayDrawer: OverlayDrawer
	init: func (context: GpuContext){
		super(context)
		this _quad = Quad create()
		this overlayDrawer = OverlayDrawer new(this _context)
	}
	recycle: func {
		this _context recycle(this)
	}
	free: func {
		this _quad free()
		super()
	}
	clear: func
	draw: func ~gpuimage (image: GpuImage, map: GpuMap, viewport: Viewport) {
		Fbo setViewport(viewport offset width, viewport offset height, viewport resolution width, viewport resolution height)
		map use()
		image bind(0)
		this _quad draw()
		image unbind()
	}
	draw: func ~twoGpuimages (image1: GpuImage, image2: GpuImage, map: GpuMap, viewport: Viewport) {
		Fbo setViewport(viewport offset width, viewport offset height, viewport resolution width, viewport resolution height)
		map use()
		image1 bind(0)
		image2 bind(2)
		this _quad draw()
		image1 unbind()
		image2 unbind()
	}
	draw: func (image: Image, map: GpuMap, viewport: Viewport) {
		match (image) {
			case (i: GpuImage) => {
				this draw(i, map, viewport)
			}
			case (i: RasterImage) => {
				temp := this _context createGpuImage(i)
				this draw(temp, map, viewport)
				temp recycle()
			}
			case =>
				raise("Couldnt match image type in OpenGLES3Surface")
		}
	}
	drawLines: func (pointList: VectorList<FloatPoint2D>, transform: FloatTransform2D) {
		this overlayDrawer drawLines(pointList, transform)
	}
	drawBox: func (box: FloatBox2D, transform: FloatTransform2D) {
		this overlayDrawer drawBox(box, transform)
	}
	drawPoints: func (pointList: VectorList<FloatPoint2D>, transform: FloatTransform2D) {
		this overlayDrawer drawPoints(pointList, transform)
	}
	create: static func (context: GpuContext)-> This {
		result := This new(context)
		result
	}
}
