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

import Surface, GpuPacker, GpuMonochrome, GpuYuv420Semiplanar

DummyWindow: class extends Surface {
  _context: Context
  _yPacker: GpuPackerY
  _uvPacker: GpuPackerUv
  _uPacker: GpuPackerU
  init: /* internal */ func
  _generate: /* private */ func () -> Bool {
    this _context = Context create()
    result: UInt = this _context makeCurrent()
    result == 1
  }
  create: static func -> This {
    result := This new()
    success := result _generate()
    if(success) {
      result _yPacker = GpuPackerY create(result _context)
      result _uvPacker = GpuPackerUv create(result _context)
      result _uPacker = GpuPackerU create(result _context)
    }
    success ? result : null
  }
  dispose: func {
    this _context dispose()
  }
  pack: func ~monochrome (image: GpuMonochrome) -> Pointer {
    result := this _yPacker pack(image, this _context)
    result
  }
  pack: func ~Yuv420Semiplanar(image: GpuYuv420Semiplanar) -> Pointer {
    result := gc_malloc(Pointer size * 2) as Pointer*
    result[0] = this _yPacker pack(image y, this _context)
    result[1] = this _uvPacker pack(image uv, this _context)
    result
  }
  _clear: func
  _bind: func
}
