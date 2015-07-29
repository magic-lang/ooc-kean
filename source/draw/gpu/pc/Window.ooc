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

	init: /* internal */ func (size: IntSize2D, title := "Window title") {
		this _native = X11Window new(size width, size height, title)
		super(size, OpenGLES3Context new(this _native))

		/* BEGIN Ugly hack to force the window to resize outside screen */
		this refresh()
		(this _native as X11Window) resize(size)
		/* END */

		this _monochromeToBgra = OpenGLES3MapMonochromeToBgra new(this context)
		this _bgrToBgra = OpenGLES3MapBgrToBgra new(this context)
		this _bgraToBgra = OpenGLES3MapBgra new(this context)
		this _yuvPlanarToBgra = OpenGLES3MapYuvPlanarToBgra new(this context)
		this _yuvSemiplanarToBgra = OpenGLES3MapYuvSemiplanarToBgra new(this context)
		this _yuvSemiplanarToBgraTransform = OpenGLES3MapYuvSemiplanarToBgra new(this context)

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
	_bind: override func { this _native bind() }
	_getTransformMap: func (gpuImage: GpuImage) -> OpenGLES3MapDefault {
		result := match(gpuImage) {
			case (gpuImage: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgraTransform
			case (gpuImage: GpuBgra) => this _bgraToBgra
			case (gpuImage: GpuMonochrome) => this _monochromeToBgra
			case => Debug raise("No support for drawing image format to Window"); null
		}
		result
	}
	draw: func ~gpuImage (image: GpuImage) {
		this map = this _getTransformMap(image) as OpenGLES3MapDefault
		this map model = this _createModelTransform(image size, image transform)
		this map view = this _view
		this map projection = this _projection
		this draw(func {
			image bind(0)
			this context drawQuad()
		})
	}
	draw: func (image: Image) {
		if (image instanceOf?(GpuImage)) { this draw(image as GpuImage) }
		else if (image instanceOf?(RasterImage)) {
			temp := this context createGpuImage(image as RasterImage)
			this draw(temp as GpuImage)
			temp free()
		}
		else
			Debug raise("Trying to draw unsupported image format to Window!!")
	}
	bind: /* internal */ func { this _native bind() }
	clear: /* internal */ func { this _native clear() }
	refresh: func {
		this context update()
		this clear()
	}
}
