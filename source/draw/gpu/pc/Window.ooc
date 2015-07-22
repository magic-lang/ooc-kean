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
import X11/include/x11

Window: class extends GpuSurface {
	_native: NativeWindow
	_monochromeToBgra: OpenGLES3MapMonochromeToBgra
	_bgrToBgra: OpenGLES3MapBgrToBgra
	_bgraToBgra: OpenGLES3MapBgra
	_yuvPlanarToBgra: OpenGLES3MapYuvPlanarToBgra
	_yuvSemiplanarToBgra, _yuvSemiplanarToBgraTransform: OpenGLES3MapYuvSemiplanarToBgra
	context ::= this _context as OpenGLES3Context
	size ::= this _size

	init: /* internal */ func (size: IntSize2D, title: String) {
		this _native = X11Window new(size width, size height, title)
		super(size, OpenGLES3Context new(this _native), FloatTransform2D createScaling(2.0f / size width, -2.0f / size height))

		/* BEGIN Ugly hack to force the window to resize outside screen */
		this refresh()
		(this _native as X11Window) resize(size)
		/* END */

		this _monochromeToBgra = OpenGLES3MapMonochromeToBgra new(this context)
		this _bgrToBgra = OpenGLES3MapBgrToBgra new(this context)
		this _bgraToBgra = OpenGLES3MapBgra new(this context, true)
		this _yuvPlanarToBgra = OpenGLES3MapYuvPlanarToBgra new(this context)
		this _yuvSemiplanarToBgra = OpenGLES3MapYuvSemiplanarToBgra new(this context)
		this _yuvSemiplanarToBgraTransform = OpenGLES3MapYuvSemiplanarToBgra new(this context, true)

		XSelectInput(this _native display, this _native _backend, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask)
		XkbSetDetectableAutoRepeat(this _native display, true, null) as Void
	}
	free: override func {
		this _bgrToBgra free()
		this _bgraToBgra free()
		this _yuvPlanarToBgra free()
		this _yuvSemiplanarToBgra free()
		this _yuvSemiplanarToBgraTransform free()
		this _monochromeToBgra free()
		native := this _native
		this _context free()
		super()
		(native as X11Window) free()
	}
	getTransformMap: func (gpuImage: GpuImage) -> OpenGLES3MapDefault {
		result := match(gpuImage) {
			case (gpuImage: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgraTransform
			case (gpuImage: GpuBgra) => this _bgraToBgra
			case (gpuImage: GpuMonochrome) => this _monochromeToBgra
			case => Debug raise("No support for drawing image format to Window"); null
		}
		result
	}
	draw: func ~Transform2D (image: GpuImage, transform := FloatTransform2D identity) {
		map := this getTransformMap(image)
		map transform = transform
		map projection = this _projection
		map reference = image reference
		this draw(image, map)
	}
	draw: func ~RasterImageTransform (image: RasterImage, transform: FloatTransform2D) {
		result := this context createGpuImage(image)
		this draw(result, transform)
		result free()
	}
	draw: func ~UnknownFormat (image: Image, transform := FloatTransform2D identity) {
		if (image instanceOf?(RasterImage))
			this draw(image as RasterImage, transform)
		else if (image instanceOf?(GpuImage))
			this draw(image as GpuImage, transform)
	}
	draw: func ~shader (image: GpuImage, map: GpuMap) {
		offset := IntPoint2D new(this size width / 2 - image size width / 2, this size height / 2 - image size height / 2)
		viewport := IntBox2D new(offset, image size)
		image bind(0)
		map use()
		this context setViewport(this viewport)
		this context drawQuad()
	}
	bind: /* internal */ func { this _native bind() }
	clear: /* internal */ func { this _native clear() }
	refresh: func {
		this context update()
		this clear()
	}
	create: static func (size: IntSize2D, title := "Window title") -> This {
		result := This new(size, title)
		result
	}
}
