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

import OpenGLES3/Quad
import OpenGLES3/NativeWindow
import OpenGLES3/Context
import OpenGLES3/X11Window

import Surface, GpuImage, GpuMonochrome, GpuBgra, GpuYuv420, GpuYuv420Semiplanar, GpuBgr, GpuMap

Window: class extends Surface {
  _native: NativeWindow
  _context: Context

  monochromeToBgra: GpuMapMonochromeToBgra
  bgrToBgra: GpuMapBgrToBgra
  bgraToBgra: GpuMapBgra
  yuvToBgra: GpuMapYuvToBgra

  init: func (=size)
  _generate: func (size: IntSize2D, title: String) -> Bool {
    this _native = X11Window create(size width, size height, title)
    this _context = Context create(_native)
    result: UInt = this _context makeCurrent()
    this quad = Quad create()
    this monochromeToBgra = GpuMapMonochromeToBgra new()
    this bgrToBgra = GpuMapBgrToBgra new()
    this bgraToBgra = GpuMapBgra new()
    this yuvToBgra = GpuMapYuvToBgra new()
    result == 1 && (this _native != null) && (this _context != null) && (this quad != null)
  }
  draw: func ~Monochrome (image: GpuMonochrome, transform := FloatTransform2D identity) {
    monochromeToBgra transform = transform
    monochromeToBgra ratio = image ratio
    this draw(image, monochromeToBgra)
  }
  draw: func ~Bgr (image: GpuBgr, transform := FloatTransform2D identity) {
    bgrToBgra transform = transform
    bgrToBgra ratio = image ratio
    this draw(image, bgrToBgra)
  }
  draw: func ~Bgra (image: GpuBgra, transform := FloatTransform2D identity) {
    bgraToBgra transform = transform
    bgraToBgra ratio = image ratio
    this draw(image, bgraToBgra)
  }
  draw: func ~Yuv (image: GpuYuv420, transform := FloatTransform2D identity) {
    yuvToBgra transform = transform
    yuvToBgra ratio = image ratio
    this draw(image, yuvToBgra)
  }
  draw: func ~RasterBgr (image: RasterBgr, transform := FloatTransform2D identity) {
    result := GpuImage create(image)
    this draw(result, transform)
    result dispose()
  }
  draw: func ~RasterBgra (image: RasterBgra, transform := FloatTransform2D identity) {
    result := GpuImage create(image)
    this draw(result, transform)
    result dispose()
  }
  draw: func ~RasterMonochrome (image: RasterMonochrome, transform := FloatTransform2D identity) {
    result := GpuImage create(image)
    this draw(result, transform)
    result dispose()
  }
  draw: func ~RasterYuv (image: RasterYuv420, transform := FloatTransform2D identity) {
    result := GpuImage create(image)
    this draw(result, transform)
    result dispose()
  }
  bind: func {
    this _native bind()
  }
  clear: func {
    this _native clear()
  }
  update: func {
    this _context swapBuffers()
  }
  setResolution: func (resolution: IntSize2D) {
    this _native setViewport(this size width / 2 - resolution width / 2, this size height / 2 - resolution height / 2, resolution width, resolution height)
  }
  create: static func (size: IntSize2D, title := "Window title") -> This {
    result := Window new(size)
    (result _generate(size, title)) ? result : null
  }
}
