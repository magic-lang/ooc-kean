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

import OpenGLES3/Context

import Surface, GpuPacker, GpuMonochrome, GpuYuv420Semiplanar, RasterMonochrome

DummyWindow: class extends Surface {
  _instance: static This
  _context: Context
  _yPacker: GpuPackerY
  _uvPacker: GpuPackerUv
  _uPacker: GpuPackerU
  init: /* internal */ func
  _generate: /* private */ func (other: Context) -> Bool {
    this _context = Context create(other)
    result: UInt = this _context makeCurrent()
    result == 1
  }
  create: static func (other: DummyWindow)-> This {
    result := This new()
    This _instance = result
    success := false
    if(other != null)
      success = result _generate(other _context)
    else
      success = result _generate(null)

    if(success) {
      result _yPacker = GpuPackerY create(result _context)
      result _uvPacker = GpuPackerUv create(result _context)
      result _uPacker = GpuPackerU create(result _context)
    }
    success ? result : null
  }
  dispose: func {
    this _yPacker dispose()
    this _uvPacker dispose()
    this _uPacker dispose()
    this _context dispose()
  }
  packPyramid: func ~monochrome (image: RasterMonochrome, count: Int) -> Pointer {
    result := this _yPacker packPyramid(image, count)
    result
  }
  pack: func ~Yuv420Semiplanar(image: GpuYuv420Semiplanar, destination: UInt8*, channelOffset: UInt) {
    yPixels := this _yPacker pack(image y)
    paddedBytes := 640 + 1920 - image size width;
    for(row in 0..image size height) {
      sourceRow := yPixels + row * (image size width + paddedBytes)
      destinationRow := destination + row * image size width
      memcpy(destinationRow, sourceRow, image size width)
    }
    this _yPacker unlock()

    uvPixels := this _uvPacker pack(image uv)
    uvDestination := destination + image size width * image size height + channelOffset
    for(row in 0..image size height / 2) {
      sourceRow := uvPixels + row * (image size width + paddedBytes)
      destinationRow := uvDestination + row * image size width
      memcpy(destinationRow, sourceRow, image size width)
    }
    this _uvPacker unlock()
  }
  _clear: func
  _bind: func
}
