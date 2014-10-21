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
use ooc-opengl

import X11/X11Window
import GpuMapPC

Window: class  {
	/*
	_native: NativeWindow
	_context: Context
	_surface: GpuSurface
	_monochromeToBgra: OpenGLES3MapMonochromeToBgra
	_bgrToBgra: OpenGLES3MapBgrToBgra
	_bgraToBgra: OpenGLES3MapBgra
	_yuvPlanarToBgra: OpenGLES3MapYuvPlanarToBgra
	_yuvSemiplanarToBgra: OpenGLES3MapYuvSemiplanarToBgra
	_quad: Quad

	init: /* internal */ func (=size) {
	}
	_generate: /* private */ func (size: IntSize2D, title: String) -> Bool {
		//this _native = X11Window create(size width, size height, title)
		this _context = Context create(_native)
		this _surface = OpenGLES3Surface create()
		result: UInt = this _context makeCurrent()
		this _quad = Quad create()
		setShaderSources()
		this _monochromeToBgra = GpuMapMonochromeToBgra new()
		this _bgrToBgra = GpuMapBgrToBgra new()
		this _bgraToBgra = GpuMapBgra new()
		this _yuvPlanarToBgra = GpuMapYuvPlanarToBgra new()
		this _yuvSemiplanarToBgra = GpuMapYuvSemiplanarToBgra new()
		result == 1 && (this _native != null) && (this _context != null) && (this _quad != null)
	}
	draw: func (image: Image, map: GpuMap, resolution: IntSize2D) {

	}
	draw: func ~Monochrome (image: GpuMonochrome, transform := FloatTransform2D identity) {
		/*
		this _monochromeToBgra transform = transform
		this _monochromeToBgra imageSize = image size
		this _monochromeToBgra screenSize = image size
		this _surface draw(image, _monochromeToBgra)
		*/
	}
	draw: func ~Bgr (image: GpuBgr, transform := FloatTransform2D identity) {
		/*
		this _bgrToBgra transform = transform
		this _bgrToBgra imageSize = image size
		this _bgrToBgra screenSize = image size
		this _surface draw(image, _bgrToBgra)
		*/
	}
	draw: func ~Bgra (image: GpuBgra, transform := FloatTransform2D identity) {
		/*
		this _bgraToBgra transform = transform
		this _bgraToBgra imageSize = image size
		this _bgraToBgra screenSize = image size
		this _surface draw(image, _bgraToBgra)
		*/
	}
	draw: func ~Yuv420Planar (image: GpuYuv420Planar, transform := FloatTransform2D identity) {
		/*
		this _yuvPlanarToBgra transform = transform
		this _yuvPlanarToBgra imageSize = image size
		this _yuvPlanarToBgra screenSize = image size
		this _surface draw(image, _yuvPlanarToBgra)
		*/
	}
	draw: func ~Yuv420Semiplanar (image: GpuYuv420Semiplanar, transform := FloatTransform2D identity) {
		/*
		this _yuvSemiplanarToBgra transform = transform
		this _yuvSemiplanarToBgra imageSize = image size
		this _yuvSemiplanarToBgra screenSize = image size
		this _surface draw(image, this _yuvSemiplanarToBgra)
		this drawLines(transform, this size)
		*/
	}
	draw: func ~RasterBgr (image: RasterBgr, transform := FloatTransform2D identity) {
		/*
		result := OpenGLES3Image create(image)
		this _surface draw(result, transform)
		result recycle()
		*/
	}
	draw: func ~RasterBgra (image: RasterBgra, transform := FloatTransform2D identity) {
		/*
		result := OpenGLES3Image create(image)
		this _surface draw(result, transform)
		result recycle()
		*/
	}
	draw: func ~RasterMonochrome (image: RasterMonochrome, transform := FloatTransform2D identity) {
		/*
		result := OpenGLES3Image create(image)
		this _surface draw(result, transform)
		result recycle()
		*/
	}
	draw: func ~RasterYuv (image: RasterYuv420Planar, transform := FloatTransform2D identity) {
		/*
		result := OpenGLES3Image create(image)
		this _surface draw(result, transform)
		result recycle()
		*/
	}
	draw: func ~RasterYuvSemiplanar (image: RasterYuv420Semiplanar, transform := FloatTransform2D identity) {
		/*
		result := OpenGLES3Image create(image)
		this _surface draw(result, transform)
		result recycle()
		*/
	}
	draw: func ~UnknownFormat (image: Image, transform := FloatTransform2D identity) {
		if (image instanceOf?(RasterBgr))
			this draw(image as RasterBgr, transform)
		else if (image instanceOf?(RasterBgra))
			this draw(image as RasterBgra, transform)
		else if (image instanceOf?(RasterMonochrome))
			this draw(image as RasterMonochrome, transform)
		else if (image instanceOf?(RasterYuv420Planar))
			this draw(image as RasterYuv420Planar, transform)
		else if (image instanceOf?(RasterYuv420Semiplanar))
			this draw(image as RasterYuv420Semiplanar, transform)
	}
	bind: /* internal */ func {
		this _native bind()
	}
	clear: /* internal */ func {
		this _native clear()
	}
	update: func {
		this _context swapBuffers()
	}
	setResolution: /* internal */ func (resolution: IntSize2D) {
		this _native setViewport(this size width / 2 - resolution width / 2, this size height / 2 - resolution height / 2, resolution width, resolution height)
	}
	create: static func (size: IntSize2D, title := "Window title") -> This {
		result := This new(size)
		result _generate(size, title) ? result : null
	}
	*/
}
