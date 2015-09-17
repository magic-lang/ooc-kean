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
	_monochromeToBgra: OpenGLMapMonochromeToBgra
	_yuvSemiplanarToBgra: OpenGLMapYuvSemiplanarToBgra

	context ::= this _context as OpenGLContext
	size ::= this _size

	init: /* internal */ func (size: IntSize2D, title := "Window title") {
		this _native = X11Window new(size width, size height, title)
		context := OpenGLContext new(this _native)
		super(size, context, OpenGLMapDefaultTexture new(this context), IntTransform2D createScaling(1, -1))

		/* BEGIN Ugly hack to force the window to resize outside screen */
		this refresh()
		(this _native as X11Window) resize(size)
		/* END */

		this _monochromeToBgra = OpenGLMapMonochromeToBgra new(this context)
		this _yuvSemiplanarToBgra = OpenGLMapYuvSemiplanarToBgra new(this context)

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
	_getDefaultMap: override func (image: Image) -> GpuMap {
		result := match (image) {
			case (i: GpuYuv420Semiplanar) => this _yuvSemiplanarToBgra
			case (i: RasterYuv420Semiplanar) => this _yuvSemiplanarToBgra
			case (i: GpuMonochrome) => this _monochromeToBgra
			case (i: RasterMonochrome) => this _monochromeToBgra
			case => this context defaultMap
		}
		result
	}
	clear: func { this _native clear() }
	refresh: func {
		this context update()
		this clear()
	}
}
