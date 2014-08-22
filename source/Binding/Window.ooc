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

import Surface, GpuImage, GpuCanvas, GpuMonochrome, GpuBgra, GpuYuv420, GpuBgr, GpuMap

Window: class extends Surface {
  native: NativeWindow
  context: Context

  monochromeToBgra: GpuMapMonochromeToBgra
  bgrToBgra: GpuMapBgrToBgra
  bgraToBgra: GpuMapBgra
  yuvToBgra: GpuMapYuvToBgra

  init: func (size: IntSize2D) {
    this size = size
    this ratio = (size width) as Float / (size height) as Float
  }
  _generate: func (size: IntSize2D, title: String) -> Bool {
    this native = X11Window create(size width, size height, title)
    this context = Context create(native)
    result: UInt = this context makeCurrent()
    this quad = Quad create(this ratio)
    this monochromeToBgra = GpuMapMonochromeToBgra new()
    this bgrToBgra = GpuMapBgrToBgra new()
    this bgraToBgra = GpuMapBgra new()
    this yuvToBgra = GpuMapYuvToBgra new()
    result == 1 && (this native != null) && (this context != null) && (this quad != null)
  }


  draw: func ~Monochrome (image: GpuMonochrome, transform: FloatTransform2D) {
    monochromeToBgra transform = transform
    monochromeToBgra ratio = this ratio
    this draw(image, monochromeToBgra)
  }

  draw: func ~Bgr (image: GpuBgr, transform: FloatTransform2D) {
    bgrToBgra transform = transform
    bgrToBgra ratio = this ratio
    this draw(image, bgrToBgra)
  }

  draw: func ~Bgra (image: GpuBgra, transform: FloatTransform2D) {
    bgraToBgra transform = transform
    bgraToBgra ratio = this ratio
    this draw(image, bgraToBgra)
  }
  draw: func ~Yuv (image: GpuYuv420, transform: FloatTransform2D) {
    yuvToBgra transform = transform
    yuvToBgra ratio = this ratio
    this draw(image, yuvToBgra)
  }

  bind: func {
    this native bind()
  }
  clear: func {
    this native clear()
  }
  update: func {
    this context swapBuffers()
  }
  create: static func (size: IntSize2D, title: String) -> This {
    result := Window new(size)
    (result _generate(size, title)) ? result : null
  }
}
