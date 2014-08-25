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

import OpenGLES3/Texture
import GpuPlanar, GpuMonochrome

GpuYuv420: class extends GpuPlanar {

  init: func (=size)

  copy: func -> This {
    result := This new(this size)
    //FIXME: null check
    result
  }

  _generate: func (y: Pointer, u: Pointer, v: Pointer) -> Bool{
    this _y = GpuMonochrome create(this size, y)
    this _u = GpuMonochrome create(this size / 2, u)
    this _v = GpuMonochrome create(this size / 2, v)

    this _y != null && this _u != null && this _v != null
  }

  create: func (size: IntSize2D) -> This {
    result := This new(size)
    //FIXME: null check
    result
  }
  create: static func ~fromPixels (size: IntSize2D, y: Pointer, u: Pointer, v: Pointer) -> This {
    result := This new(size)
    result _generate(y, u, v) ? result : null
    //FIXME: null check
    result
  }
}
