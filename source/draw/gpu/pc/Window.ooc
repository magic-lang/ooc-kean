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
	_yuvSemiplanarToBgra: OpenGLES3MapYuvSemiplanarToBgra

	context ::= this _context as OpenGLES3Context
	size ::= this _size

	init: /* internal */ func (size: IntSize2D, title := "Window title") {
		this _native = X11Window new(size width, size height, title)
		context := OpenGLES3Context new(this _native)
		super(size, context, OpenGLES3MapDefaultTexture new(this context), IntTransform2D createScaling(1, -1))

		/* BEGIN Ugly hack to force the window to resize outside screen */
		this refresh()
		(this _native as X11Window) resize(size)
		/* END */

		this _monochromeToBgra = OpenGLES3MapMonochromeToBgra new(this context)
		this _yuvSemiplanarToBgra = OpenGLES3MapYuvSemiplanarToBgra new(this context)

		XSelectInput(this _native display, this _native _backend, KeyPressMask | KeyReleaseMask | ButtonPressMask | ButtonReleaseMask)
		XkbSetDetectableAutoRepeat(this _native display, true, null) as Void
	}
	free: override func {
		this _yuvSemiplanarToBgra free()
		this _monochromeToBgra free()
		this _defaultMap free()
		native := this _native
		this _context free()
		super()
		(native as X11Window) free()
	}
	_bind: override func { this _native bind() }
	_getTransformMap: func (gpuImage: GpuImage) -> GpuMap {
		result := match(gpuImage) {
			case (gpuImage: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgra
			case (gpuImage: GpuMonochrome) => this _monochromeToBgra
			case => this context getMap(gpuImage, GpuMapType transform)
		}
		result
	}
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D) {
		this map = this _getTransformMap(image)
		super(image, source, destination)
	}
	clear: func { this _native clear() }
	refresh: func {
		this context update()
		this clear()
	}
}
