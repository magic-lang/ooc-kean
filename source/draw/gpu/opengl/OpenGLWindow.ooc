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

use ooc-geometry
use ooc-draw
use ooc-draw-gpu
use ooc-opengl
use ooc-base

version(!gpuOff) {
OpenGLWindow: class extends OpenGLSurface {
	_monochromeToBgra: OpenGLMap
	_yuvSemiplanarToBgra: OpenGLMapTransform
	init: func (windowSize: IntVector2D, display: Pointer, nativeBackend: Long) {
		context := OpenGLContext new(display, nativeBackend)
		super(windowSize, context, OpenGLMap new(slurp("shaders/texture.frag"), context), IntTransform2D createScaling(1, -1))
		this _monochromeToBgra = OpenGLMap new(slurp("shaders/monochromeToBgra.frag"), context)
		this _yuvSemiplanarToBgra = OpenGLMapTransform new(slurp("shaders/yuvSemiplanarToBgra.frag"), context)
	}
	free: override func {
		this _yuvSemiplanarToBgra free()
		this _monochromeToBgra free()
		this _defaultMap free()
		this _context free()
		super()
	}
	_bind: override func
	_unbind: override func
	_getDefaultMap: override func (image: Image) -> GpuMap {
		match (image class) {
			case GpuYuv420Semiplanar => this _yuvSemiplanarToBgra
			case RasterYuv420Semiplanar => this _yuvSemiplanarToBgra
			case OpenGLMonochrome => this _monochromeToBgra
			case RasterMonochrome => this _monochromeToBgra
			case => this context defaultMap
		}
	}
	refresh: func { this context update() }
	fill: override func
}
}
