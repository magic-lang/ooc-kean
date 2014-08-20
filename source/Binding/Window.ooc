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

import OpenGLES3/Quad
import OpenGLES3/NativeWindow
import OpenGLES3/Context
import OpenGLES3/X11Window

import Surface, GpuImage, GpuCanvas

Window: class extends Surface {
  native: NativeWindow
  context: Context

  init: func (size: IntSize2D) {
    this size = size
  }

  create: static func (size: IntSize2D, title: String) -> This {
    result := Window new(size)
    (result _generate(size, title)) ? result : null
  }

  _generate: func (size: IntSize2D, title: String) -> Bool {
    this native = X11Window create(size width, size height, title)
    this context = Context create(native)
    result: UInt = this context makeCurrent()
    result == 1 && (native != null) && (context != null)
  }

  draw: func (image: GpuImage, transform: FloatTransform2D) {
    image bind(transform, true)
    Quad draw()
    image unbind()
  }

  draw: func ~canvas (canvas: GpuCanvas) {
    canvas bind(true)
    Quad draw()
    canvas unbind()
  }

  update: func {
    this context update()
  }

}
