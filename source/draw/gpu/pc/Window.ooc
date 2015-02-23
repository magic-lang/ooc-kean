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
use ooc-base

import X11/X11Window

Window: class extends OpenGLES3Context {
	_native: NativeWindow
	_monochromeToBgra: OpenGLES3MapMonochromeToBgra
	_bgrToBgra: OpenGLES3MapBgrToBgra
	_bgraToBgra: OpenGLES3MapBgra
	_yuvPlanarToBgra: OpenGLES3MapYuvPlanarToBgra
	_yuvSemiplanarToBgra, _yuvSemiplanarToBgraTransform: OpenGLES3MapYuvSemiplanarToBgra

	size: IntSize2D { get set }

	init: /* internal */ func (=size, title: String) {
		this _native = X11Window create(size width, size height, title)
		super(this _native)
		this _monochromeToBgra = OpenGLES3MapMonochromeToBgra new(this)
		this _bgrToBgra = OpenGLES3MapBgrToBgra new(this)
		this _bgraToBgra = OpenGLES3MapBgra new(this)
		this _yuvPlanarToBgra = OpenGLES3MapYuvPlanarToBgra new(this)
		this _yuvSemiplanarToBgra = OpenGLES3MapYuvSemiplanarToBgra new(this)
		this _yuvSemiplanarToBgraTransform = OpenGLES3MapYuvSemiplanarToBgra new(this, true)
	}
	free: override func {
		this _bgrToBgra free()
		this _bgraToBgra free()
		this _yuvPlanarToBgra free()
		this _yuvSemiplanarToBgra free()
		this _monochromeToBgra free()
		super()
	}
	getTransformMap: func (gpuImage: GpuImage) -> OpenGLES3MapDefault {
		result := match(gpuImage) {
			case (gpuImage: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgraTransform
			case => null
		}
		if (result == null) {
			DebugPrint print("No support for drawing image format to Window")
			raise("No support for drawing image format to Window")
		}
		result
	}
	draw: func ~Transform2D (image: GpuImage, transform := FloatTransform2D identity) {
		map := this getTransformMap(image)
		map transform = FloatTransform2D createScaling(1.0f, -1.0f) * transform
		this draw(image, map)
	}
	draw: func ~RasterImageTransform (image: RasterImage, transform: FloatTransform2D) {
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
	draw: func ~shader (image: GpuImage, map: GpuMap) {
		offset := IntSize2D new(this size width / 2 - image size width / 2, this size height / 2 - image size height / 2)
		viewport := Viewport new(offset, image size)
		surface := this createSurface()
		surface draw(image, map, viewport)
		surface recycle()
	}
	bind: /* internal */ func { this _native bind() }
	clear: /* internal */ func { this _native clear() }
	refresh: func {
		this update()
		this clear()
	}
	create: static func (size: IntSize2D, title := "Window title") -> This {
		result := This new(size, title)
		result
	}
}
