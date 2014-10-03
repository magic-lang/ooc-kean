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
import GpuMonochrome, GpuCanvas, GpuPlanar, GpuUv

GpuYuv420Semiplanar: class extends GpuPlanar {
  _canvas: GpuCanvasYuv420Semiplanar
  _y: GpuMonochrome
  y: GpuMonochrome { get { this _y } }
  _uv: GpuUv
  uv: GpuUv { get { this _uv } }

  canvas: GpuCanvasYuv420Semiplanar {
    get {
      if (this _canvas == null)
        this _canvas = GpuCanvasYuv420Semiplanar create(this)
      this _canvas
    }
  }
  init: /* private */ func (=size)
  dispose: func {
    this _y dispose()
    this _uv dispose()
    if(this _canvas != null)
      this _canvas dispose()
  }
  recycle: func {
    this _y recycle()
    this _uv recycle()
  }
  _bind: /* internal */ func {
    this _y _bind(0)
    this _uv _bind(1)
  }
  _generate: func (y: Pointer, uv: Pointer) -> Bool {
    this _y = GpuMonochrome _create(this size, y)
    this _uv = GpuUv _create(this size / 2, uv)
    this _y != null && this _uv != null
  }
  create: func (size: IntSize2D) -> This {
    result := This new(size)
    result _generate(null, null) ? result : null
  }
  create2: static func ~empty (size: IntSize2D) -> This {
    result := This new(size)
    result _generate(null, null) ? result : null
  }
  _create: static /* internal */ func ~fromPixels (size: IntSize2D, y: Pointer, uv: Pointer) -> This {
    result := This new(size)
    result _generate(y, uv) ? result : null
  }
}
