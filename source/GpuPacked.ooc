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
use ooc-draw
use ooc-math
import OpenGLES3/Texture
import GpuImage, GpuCanvas

GpuPacked: abstract class extends GpuImage {
	_canvas: GpuCanvasPacked
	canvas: GpuCanvasPacked {
		get {
			if (this _canvas == null)
				this _canvas = GpuCanvasPacked create(this)
			this _canvas
		}
	}
	init: func (size: IntSize2D, type: TextureType, data: Pointer) {
		super(size)
		this _texture = Texture create(type, size width, size height, data)
	}
	_bind: /* internal */ func ~specificTextureUnit(unit: UInt) {
		this _texture bind (unit)
	}
	_bind: /* internal */ func {
		this _texture bind (0)
	}
	dispose: func {
		this _texture dispose()
		if(this _canvas != null)
			this _canvas dispose()
	}
	recycle: func {
		this _texture recycle()
	}
	generateMipmap: func {
		this _texture generateMipmap()
	}

}
