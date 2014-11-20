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

Window: class extends OpenGLES3Context {
	_native: NativeWindow
	_monochromeToBgra: OpenGLES3MapMonochromeToBgra
	_bgrToBgra: OpenGLES3MapBgrToBgra
	_bgraToBgra: OpenGLES3MapBgra
	_yuvPlanarToBgra: OpenGLES3MapYuvPlanarToBgra
	_yuvSemiplanarToBgra: OpenGLES3MapYuvSemiplanarToBgra
	size: IntSize2D { get set }

	init: /* internal */ func (=size, title: String) {
		setShaderSources()
		this _native = X11Window create(size width, size height, title)
		super(this _native, func { this onDispose() })
		this _monochromeToBgra = OpenGLES3MapMonochromeToBgra new()
		this _bgrToBgra = OpenGLES3MapBgrToBgra new()
		this _bgraToBgra = OpenGLES3MapBgra new()
		this _yuvPlanarToBgra = OpenGLES3MapYuvPlanarToBgra new()
		this _yuvSemiplanarToBgra = OpenGLES3MapYuvSemiplanarToBgra new()
	}
	onDispose: func {
		this _bgrToBgra dispose()
		this _bgraToBgra dispose()
		this _yuvPlanarToBgra dispose()
		this _yuvSemiplanarToBgra dispose()
	}
	getWindowMap: func (gpuImage: GpuImage) -> OpenGLES3MapDefault {
		result := match(gpuImage) {
			case (i: GpuMonochrome) => this _monochromeToBgra
			case (i: GpuBgr) => this _bgrToBgra
			case (i: GpuBgra) => this _bgraToBgra
			case (i: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgra
			case (i: GpuYuv420Planar) => this _yuvPlanarToBgra
		}
		result
	}
	draw: func ~GpuImage (image: GpuImage, transform := FloatTransform2D identity) {
		map := this getWindowMap(image)
		map transform = transform
		map imageSize = image size
		map screenSize = IntSize2D new(image size width, -image size height)
		offset := IntSize2D new(this size width / 2 - image size width / 2, this size height / 2 - image size height / 2)
		surface := OpenGLES3Surface create(this)
		viewport := Viewport new(offset, image size)
		surface draw(image, map, viewport)
		surface recycle()
	}
	draw: func ~RasterImage (image: RasterImage, transform := FloatTransform2D identity) {
		result := this createGpuImage(image)
		this draw(result, transform)
		result recycle()
	}
	draw: func ~UnknownFormat (image: Image, transform := FloatTransform2D identity) {
		if (image instanceOf?(RasterImage))
			this draw(image as RasterImage, transform)
		else if (image instanceOf?(GpuImage))
			this draw(image as GpuImage, transform)
	}
	draw: func ~shader(image: GpuImage, map: GpuMap) {
		offset := IntSize2D new(this size width / 2 - image size width / 2, this size height / 2 - image size height / 2)
		viewport := Viewport new(offset, image size)
		surface := OpenGLES3Surface create(this)
		surface draw(image, map, viewport)
		surface recycle()
	}
	bind: /* internal */ func {
		this _native bind()
	}
	clear: /* internal */ func {
		this _native clear()
	}
	refresh: func {
		this update()
		this clear()
	}
	create: static func (size: IntSize2D, title := "Window title") -> This {
		result := This new(size, title)
		result
	}
}
